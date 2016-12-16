From: Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org>
Subject: Re: [PATCH 2/3] NFC: trf7970a: Add device tree option of 1.8 Volt IO
 voltage
Date: Thu, 15 Dec 2016 18:13:41 -0700
Message-ID: <20161216011341.GB25227@animalcreek.com>
References: <1481841044-4314-1-git-send-email-glansberry@gmail.com>
 <1481841044-4314-2-git-send-email-glansberry@gmail.com>
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
In-Reply-To: <1481841044-4314-2-git-send-email-glansberry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 05:30:43PM -0500, Geoff Lansberry wrote:
> From: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>

Missing commit description.

> diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
> index 2d2a077..b4c37ab 100644
> --- a/drivers/nfc/trf7970a.c
> +++ b/drivers/nfc/trf7970a.c

> @@ -1048,6 +1049,11 @@ static int trf7970a_init(struct trf7970a *trf)
>  	if (ret)
>  		goto err_out;
>  
> +	ret = trf7970a_write(trf, TRF7970A_REG_IO_CTRL,
> +			trf->io_ctrl|TRF7970A_REG_IO_CTRL_VRS(0x1));

s/l|T/l | T/

Otherwise, looks good.

Mark
--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
