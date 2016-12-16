From: Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org>
Subject: Re: [PATCH 1/3] NFC: trf7970a: add device tree option for 27MHz clock
Date: Thu, 15 Dec 2016 18:06:13 -0700
Message-ID: <20161216010613.GA25227@animalcreek.com>
References: <1481841044-4314-1-git-send-email-glansberry@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
        aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org
To: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1481841044-4314-1-git-send-email-glansberry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Geoff.

On Thu, Dec 15, 2016 at 05:30:42PM -0500, Geoff Lansberry wrote:
> From: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>

Please add an informative commit description to all of your commits.
No matter how trivial this patch may seem to you now, it may not be
to others (or to you in a few years).

> diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
> index 26c9dbb..2d2a077 100644
> --- a/drivers/nfc/trf7970a.c
> +++ b/drivers/nfc/trf7970a.c

> @@ -1181,27 +1180,37 @@ static int trf7970a_in_config_rf_tech(struct trf7970a *trf, int tech)
>  	switch (tech) {
>  	case NFC_DIGITAL_RF_TECH_106A:
>  		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_14443A_106;
> -		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_OOK;
> +		trf->modulator_sys_clk_ctrl =
> +			(trf->modulator_sys_clk_ctrl & 0xF8) |

nit: s/0xF8/0xf8/ please (for consistency with the rest of the file.).

Otherwise, it looks good.

Thanks,

Mark
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
