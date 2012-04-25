From: "Linus Walleij" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 00/14 v2] usb/net: rndis: first step toward consolidation
Date: Wed, 25 Apr 2012 17:29:43 +0200
Message-ID: <1335367783-4184-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A second spin of the RNDIS unification patches.
Jussi Kivilinna pointed out an error where I was joining
"media" and "physical media" in patch 9, this was all wrong
so now I've fixed it up.

Please test!

If this thing works I guess it should propagate through
dmillers tree eventually.

Linus Walleij (14):
  usb/net: rndis: inline the cpu_to_le32() macro
  usb/net: rndis: break out <linux/rndis.h> defines
  usb/net: rndis: remove duplicate definitions
  usb/net: rndis: remove ambigous status codes
  usb/net: rndis: eliminate first set of duplicate OIDs
  usb/net: rndis: merge duplicate 802_* OIDs
  usb/net: rndis: delete surplus defines
  usb/net: rndis: group all status codes together
  usb/net: rndis: merge media type definitions
  usb/net: rndis: delete duplicate packet types
  usb/net: rndis: move and namespace PnP defines
  usb/net: rndis: merge command codes
  usb/net: rndis: fixup a few name prefixes
  usb/net: rndis: move bus message definition

 drivers/net/hyperv/hyperv_net.h   |  290 +---------------------------
 drivers/net/hyperv/rndis_filter.c |   46 +++---
 drivers/net/usb/rndis_host.c      |   52 +++---
 drivers/net/wireless/rndis_wlan.c |  295 ++++++++++++----------------
 drivers/usb/gadget/f_rndis.c      |    6 +-
 drivers/usb/gadget/ndis.h         |  164 ----------------
 drivers/usb/gadget/rndis.c        |  271 +++++++++++++-------------
 drivers/usb/gadget/rndis.h        |   48 +-----
 include/linux/rndis.h             |  390 +++++++++++++++++++++++++++++++++++++
 include/linux/usb/rndis_host.h    |   66 +------
 10 files changed, 706 insertions(+), 922 deletions(-)
 create mode 100644 include/linux/rndis.h

-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
