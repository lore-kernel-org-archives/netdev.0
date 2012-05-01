From: Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
Subject: RE: [PATCH 02/13 v4] usb/net: rndis: break out <linux/rndis.h>
 defines
Date: Tue, 1 May 2012 18:54:54 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD3CAAA@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1335896546-13315-1-git-send-email-linus.walleij@linaro.org>
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
In-Reply-To: <1335896546-13315-1-git-send-email-linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Linus Walleij [mailto:linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org]
> Sent: Tuesday, May 01, 2012 2:22 PM
> To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Greg Kroah-Hartman;
> David S. Miller; Felipe Balbi
> Cc: Jussi Kivilinna; Haiyang Zhang; Wei Yongjun; Ben Hutchings; Linus
> Walleij
> Subject: [PATCH 02/13 v4] usb/net: rndis: break out <linux/rndis.h>
> defines
> 
> As a first step to consolidate the RNDIS implementations, break out
> a common file with all the #defines and move it to <linux/rndis.h>.
> The compilation screams about double-defines all over the place
> (as could be expected, this is why we're consolidating) but it
> compiles cleanly still.
> 
> This also deletes the immediate duplicated defines in the
> <linux/rndis.h> file that yields a lot of compilation warnings.
> 
> Reviewed-by: Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
> Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
> ChangeLog v2->v3:
> - Squashed subsequent patch removing duplicate entries into
>   this patch so it's bisectable without any compilation warnings.

I have not reviewed this version yet.

Also, I think you should merge the "ChangeLog v2->v3" into the patch
comments. Don't need to say "The compilation screams about double-defines
all over the place" any more.

Thanks,
- Haiyang


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
