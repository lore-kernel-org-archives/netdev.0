From: Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
Subject: RE: [PATCH 04/14 v2] usb/net: rndis: remove ambigous status codes
Date: Wed, 25 Apr 2012 20:39:02 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD36CBE@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1335367825-4324-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
To: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1335367825-4324-1-git-send-email-linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Linus Walleij [mailto:linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org]
> Sent: Wednesday, April 25, 2012 11:30 AM
> To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Greg Kroah-Hartman;
> David S. Miller; Felipe Balbi
> Cc: Jussi Kivilinna; Haiyang Zhang; Wei Yongjun; Ben Hutchings; Linus
> Walleij
> Subject: [PATCH 04/14 v2] usb/net: rndis: remove ambigous status codes
> 
> The RNDIS status codes are redefined with much stranged ifdeffery
> and only one of these codes was used in the hyperv driver, and
> there it is very clearly referring to the RNDIS variant, not some
> other status. So clarify this by explictly using the RNDIS_*
> prefixed status code in the hyperv drivera and delete the
> duplicate defines.
> 
> Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  drivers/net/hyperv/rndis_filter.c |    4 ++--
>  include/linux/rndis.h             |   31 +++----------------------------
>  2 files changed, 5 insertions(+), 30 deletions(-)
> 

Reviewed-by: Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
