From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 02/14 v2] usb/net: rndis: break out <linux/rndis.h> defines
Date: Fri, 27 Apr 2012 13:24:06 +0200
Message-ID: <CACRpkdZoV7FcERUnYMozFkgaog7nr9XeT91jsL4G26pGQiq4GA@mail.gmail.com>
References: <1335367808-4254-1-git-send-email-linus.walleij@linaro.org>
	<20120425.194447.1519804940735129000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org, jussi.kivilinna-E01nCVcF24I@public.gmane.org,
	haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org,
	ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120425.194447.1519804940735129000.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2012 at 1:44 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> After this patch the build emits tons of warnings because you've
> left a situation where there will be duplicate definitions:

Sure, that was on purpose, doing it step-wise so we could find
bisect if something broke in the step of ironing out the duplicate
defines. So actually it was being cautious (maybe in a bad way.)

But I'll just squash the duplication-removal patches now that
we know it works, and we end on warning-free patches.

Yours,
Linus Walleij
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
