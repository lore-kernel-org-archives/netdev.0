From: Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] net: asix: Move declaration of ax88172a_info to
 shared header
Date: Fri, 9 Aug 2013 14:39:06 -0300
Message-ID: <CAOMZO5AHVcmb8DiqM_H12e9cD3zAt0ZGz8yrLDyq5FwwO+cSMA@mail.gmail.com>
References: <1376069482-16951-1-git-send-email-broonie@kernel.org>
	<1376069482-16951-2-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
	Mark Brown <broonie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1376069482-16951-2-git-send-email-broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 9, 2013 at 2:31 PM, Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> From: Mark Brown <broonie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>
> Ensure that the definition of ax88172a_info matches the declaration seen
> by users and silence sparse warnings about symbols without declarations
> in the global namespace by moving the declaration into the shared header
> asix.h.
>
> Signed-off-by: Mark Brown <broonie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  drivers/net/usb/asix.h         | 2 ++
>  drivers/net/usb/asix_devices.c | 2 --
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
> index 346c032..bdaa12d 100644
> --- a/drivers/net/usb/asix.h
> +++ b/drivers/net/usb/asix.h
> @@ -178,6 +178,8 @@ struct asix_common_private {
>         struct asix_rx_fixup_info rx_fixup_info;
>  };
>
> +extern const struct driver_info ax88172a_info;

You could drop the 'extern' here.

All other function prototypes in this header file do not use 'extern'.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
