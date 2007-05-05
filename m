From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH 2/4 (resend)] mac80211: add mac80211 wireless stack
Date: Sat, 5 May 2007 09:44:38 -0400
Message-ID: <20070505134438.GB4155@tuxdriver.com>
References: <20070505031749.GA5308@tuxdriver.com> <20070505134255.GA4155@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070505134255.GA4155-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>

Add mac80211, the IEEE 802.11 software MAC layer.

Signed-off-by: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 include/net/mac80211.h          | 1045 ++++++++
 net/Kconfig                     |    1 +
 net/Makefile                    |    4 +-
 net/mac80211/Kconfig            |   69 +
 net/mac80211/Makefile           |   19 +
 net/mac80211/aes_ccm.c          |  155 ++
 net/mac80211/aes_ccm.h          |   26 +
 net/mac80211/hostapd_ioctl.h    |  108 +
 net/mac80211/ieee80211.c        | 4970 +++++++++++++++++++++++++++++++++++++++
 net/mac80211/ieee80211_cfg.c    |   66 +
 net/mac80211/ieee80211_cfg.h    |    9 +
 net/mac80211/ieee80211_common.h |   98 +
 net/mac80211/ieee80211_i.h      |  671 ++++++
 net/mac80211/ieee80211_iface.c  |  344 +++
 net/mac80211/ieee80211_ioctl.c  | 1806 ++++++++++++++
 net/mac80211/ieee80211_key.h    |   89 +
 net/mac80211/ieee80211_led.c    |   91 +
 net/mac80211/ieee80211_led.h    |   32 +
 net/mac80211/ieee80211_rate.c   |  140 ++
 net/mac80211/ieee80211_rate.h   |  122 +
 net/mac80211/ieee80211_sta.c    | 3060 ++++++++++++++++++++++++
 net/mac80211/michael.c          |  104 +
 net/mac80211/michael.h          |   20 +
 net/mac80211/rc80211_simple.c   |  361 +++
 net/mac80211/sta_info.c         |  386 +++
 net/mac80211/sta_info.h         |  145 ++
 net/mac80211/tkip.c             |  341 +++
 net/mac80211/tkip.h             |   36 +
 net/mac80211/wep.c              |  328 +++
 net/mac80211/wep.h              |   40 +
 net/mac80211/wme.c              |  678 ++++++
 net/mac80211/wme.h              |   57 +
 net/mac80211/wpa.c              |  660 ++++++
 net/mac80211/wpa.h              |   31 +
 34 files changed, 16110 insertions(+), 2 deletions(-)
 create mode 100644 include/net/mac80211.h
 create mode 100644 net/mac80211/Kconfig
 create mode 100644 net/mac80211/Makefile
 create mode 100644 net/mac80211/aes_ccm.c
 create mode 100644 net/mac80211/aes_ccm.h
 create mode 100644 net/mac80211/hostapd_ioctl.h
 create mode 100644 net/mac80211/ieee80211.c
 create mode 100644 net/mac80211/ieee80211_cfg.c
 create mode 100644 net/mac80211/ieee80211_cfg.h
 create mode 100644 net/mac80211/ieee80211_common.h
 create mode 100644 net/mac80211/ieee80211_i.h
 create mode 100644 net/mac80211/ieee80211_iface.c
 create mode 100644 net/mac80211/ieee80211_ioctl.c
 create mode 100644 net/mac80211/ieee80211_key.h
 create mode 100644 net/mac80211/ieee80211_led.c
 create mode 100644 net/mac80211/ieee80211_led.h
 create mode 100644 net/mac80211/ieee80211_rate.c
 create mode 100644 net/mac80211/ieee80211_rate.h
 create mode 100644 net/mac80211/ieee80211_sta.c
 create mode 100644 net/mac80211/michael.c
 create mode 100644 net/mac80211/michael.h
 create mode 100644 net/mac80211/rc80211_simple.c
 create mode 100644 net/mac80211/sta_info.c
 create mode 100644 net/mac80211/sta_info.h
 create mode 100644 net/mac80211/tkip.c
 create mode 100644 net/mac80211/tkip.h
 create mode 100644 net/mac80211/wep.c
 create mode 100644 net/mac80211/wep.h
 create mode 100644 net/mac80211/wme.c
 create mode 100644 net/mac80211/wme.h
 create mode 100644 net/mac80211/wpa.c
 create mode 100644 net/mac80211/wpa.h

Patch is huge, so it is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/mac80211/0002-mac80211-add-mac80211-wireless-stack.patch

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
