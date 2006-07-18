From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/9] d80211: pull request
Date: Tue, 18 Jul 2006 17:45:20 +0200 (CEST)
Message-ID: <20060718174442.485760904.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:39561 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932285AbWGRPnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:43:33 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git master
to obtain following patches:

Jiri Benc:
      d80211: do not receive through master interface when not scanning
      d80211: host_gen_beacon_template flag
      d80211: better deallocation of mdev
      d80211: fix receiving through virtual interfaces
      d80211: fix defragmentation
      d80211: optimize defragmentation
      d80211: SET_NETDEV_DEV for non-master devices

Michael Wu:
      d80211: Replace rc4 code with crypto api arc4
      d80211: Add sparse bitwise annotations

 include/net/d80211.h         |   12 +-
 include/net/d80211_mgmt.h    |   42 +++---
 net/d80211/Kconfig           |    1 
 net/d80211/ieee80211.c       |  290 ++++++++++++++++++++++++++++--------------
 net/d80211/ieee80211_i.h     |   19 ++-
 net/d80211/ieee80211_iface.c |   21 +++
 net/d80211/ieee80211_ioctl.c |    2 
 net/d80211/ieee80211_sta.c   |    7 -
 net/d80211/tkip.c            |   14 +-
 net/d80211/tkip.h            |   10 +
 net/d80211/wep.c             |  193 ++++++----------------------
 net/d80211/wep.h             |   11 +-
 net/d80211/wpa.c             |    8 +
 13 files changed, 327 insertions(+), 303 deletions(-)

-- 
Jiri Benc
SUSE Labs
