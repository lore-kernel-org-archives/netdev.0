From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH 0/4] add mac80211 wireless infrastructure
Date: Fri, 4 May 2007 23:17:49 -0400
Message-ID: <20070505031749.GA5308@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series adds the mac80211 component.  This is the new wireless
infrastructure for "softmac"-style wireless hardware.  It originated
as code contributed by Devicescape, and has been under development by
the community for well over a year.  Thanks are due especially to Jiri
Benc and Michael Wu as well as Johannes Berg and a number of other
contributors who have worked to hammer this into its current form.

This component was in -mm for most of the 2.6.21 cycle, with few
reported bugs.  The code is also currently available in Fedora rawhide
where it has performed well.

The wireless developers would like this to be considered for merge
in time for 2.6.22.  Patches for at least one mac80211-based driver
will follow shortly.

Thanks,

John
---

The following changes since commit dc87c3985e9b442c60994308a96f887579addc39:
  Linus Torvalds (1):
        libata: honour host controllers that want just one host

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git mac80211

Jiri Benc (4):
      mac80211: add generic include/linux/ieee80211.h
      mac80211: add mac80211 wireless stack
      mac80211: add debugfs attributes
      mac80211: add maintainers entry for mac80211

 MAINTAINERS                     |   10 +
 include/linux/ieee80211.h       |  342 +++
 include/net/mac80211.h          | 1045 ++++++++
 net/Kconfig                     |    1 +
 net/Makefile                    |    4 +-
 net/mac80211/Kconfig            |   78 +
 net/mac80211/Makefile           |   20 +
 net/mac80211/aes_ccm.c          |  155 ++
 net/mac80211/aes_ccm.h          |   26 +
 net/mac80211/debugfs.c          |  433 ++++
 net/mac80211/debugfs.h          |   16 +
 net/mac80211/debugfs_key.c      |  252 ++
 net/mac80211/debugfs_key.h      |   34 +
 net/mac80211/debugfs_netdev.c   |  440 ++++
 net/mac80211/debugfs_netdev.h   |   30 +
 net/mac80211/debugfs_sta.c      |  246 ++
 net/mac80211/debugfs_sta.h      |   12 +
 net/mac80211/hostapd_ioctl.h    |  108 +
 net/mac80211/ieee80211.c        | 4984 +++++++++++++++++++++++++++++++++++++++
 net/mac80211/ieee80211_cfg.c    |   66 +
 net/mac80211/ieee80211_cfg.h    |    9 +
 net/mac80211/ieee80211_common.h |   98 +
 net/mac80211/ieee80211_i.h      |  798 +++++++
 net/mac80211/ieee80211_iface.c  |  352 +++
 net/mac80211/ieee80211_ioctl.c  | 1822 ++++++++++++++
 net/mac80211/ieee80211_key.h    |  106 +
 net/mac80211/ieee80211_led.c    |   91 +
 net/mac80211/ieee80211_led.h    |   32 +
 net/mac80211/ieee80211_rate.c   |  140 ++
 net/mac80211/ieee80211_rate.h   |  144 ++
 net/mac80211/ieee80211_sta.c    | 3060 ++++++++++++++++++++++++
 net/mac80211/michael.c          |  104 +
 net/mac80211/michael.h          |   20 +
 net/mac80211/rc80211_simple.c   |  432 ++++
 net/mac80211/sta_info.c         |  470 ++++
 net/mac80211/sta_info.h         |  164 ++
 net/mac80211/tkip.c             |  341 +++
 net/mac80211/tkip.h             |   36 +
 net/mac80211/wep.c              |  328 +++
 net/mac80211/wep.h              |   40 +
 net/mac80211/wme.c              |  678 ++++++
 net/mac80211/wme.h              |   57 +
 net/mac80211/wpa.c              |  660 ++++++
 net/mac80211/wpa.h              |   31 +
 44 files changed, 18313 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/ieee80211.h
 create mode 100644 include/net/mac80211.h
 create mode 100644 net/mac80211/Kconfig
 create mode 100644 net/mac80211/Makefile
 create mode 100644 net/mac80211/aes_ccm.c
 create mode 100644 net/mac80211/aes_ccm.h
 create mode 100644 net/mac80211/debugfs.c
 create mode 100644 net/mac80211/debugfs.h
 create mode 100644 net/mac80211/debugfs_key.c
 create mode 100644 net/mac80211/debugfs_key.h
 create mode 100644 net/mac80211/debugfs_netdev.c
 create mode 100644 net/mac80211/debugfs_netdev.h
 create mode 100644 net/mac80211/debugfs_sta.c
 create mode 100644 net/mac80211/debugfs_sta.h
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

Individual patches can be found here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/mac80211/

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
