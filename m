From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/5] d80211: pull request
Date: Tue,  1 Aug 2006 21:16:54 +0200 (CEST)
Message-ID: <20060801211530.150852000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:48600 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751819AbWHATQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 15:16:54 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up
to obtain following patches:

Jiri Benc:
      d80211: make sleeping in hw->config possible
      d80211: return correct error codes for scan requests
      d80211: Switch d80211 drivers to IEEE80211_ style definitions

Karol Lewandowski:
      d80211: return correct value when loading of rate control module fails

Michael Wu:
      d80211: Switch d80211 to IEEE80211_ style names

 drivers/net/wireless/d80211/adm8211/adm8211.c      |   10 -
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |   12 -
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c |   15 -
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |   12 -
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |   12 -
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c     |   12 -
 drivers/net/wireless/d80211/rt2x00/rt61pci.c       |   10 -
 drivers/net/wireless/d80211/rt2x00/rt73usb.c       |   10 -
 include/net/d80211.h                               |  125 ++++---
 net/d80211/ieee80211.c                             |  343 ++++++++++----------
 net/d80211/ieee80211_i.h                           |    6 
 net/d80211/ieee80211_iface.c                       |   10 -
 net/d80211/ieee80211_ioctl.c                       |   22 +
 net/d80211/ieee80211_scan.c                        |    2 
 net/d80211/ieee80211_sta.c                         |  259 ++++++++-------
 net/d80211/ieee80211_sysfs.c                       |    2 
 net/d80211/rate_control.c                          |   10 -
 net/d80211/sta_info.c                              |   16 -
 net/d80211/tkip.c                                  |    8 
 net/d80211/wep.c                                   |    8 
 net/d80211/wme.c                                   |    8 
 net/d80211/wpa.c                                   |   72 ++--
 22 files changed, 508 insertions(+), 476 deletions(-)


-- 
Jiri Benc
SUSE Labs
