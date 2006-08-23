From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/21] d80211: pull request
Date: Wed, 23 Aug 2006 21:24:08 +0200 (CEST)
Message-ID: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:26064 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965111AbWHWTYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:09 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git master
to obtain following patches:

David Kimdon:
      d80211: allow for large scan results
      d80211: fix multiple device support
      d80211: fix interface removal

Jiri Benc:
      d80211: remove useless and wrong check for interface type

Johannes Berg:
      d80211: relax sysfs permissions
      d80211: master link
      d80211: pointers as extended booleans
      d80211: use kzalloc()
      d80211: get rid of WME bitfield
      d80211: get rid of sta_aid in favour of keeping track of TIM
      d80211: clean up exports
      d80211: clean up includes
      d80211: fix some sparse warnings
      d80211: make lowlevel TX framedump option visible
      d80211: surface IBSS debug
      d80211: get rid of MICHAEL_MIC_HWACCEL define
      d80211: surface powersave debug switch
      d80211: fix some documentation

Michael Buesch:
      d80211: add ieee80211_stop_queues()

Michael Wu:
      d80211: switch status codes, reason codes, and EIDs to enums
      d80211: Group EIDs by standard, add remaining 802.11d EIDs

 include/net/d80211.h         |  144 ++++++++++++----------
 include/net/d80211_mgmt.h    |  158 ++++++++++++++----------
 net/d80211/Kconfig           |   26 ++++
 net/d80211/aes_ccm.c         |    3 
 net/d80211/aes_ccm.h         |    2 
 net/d80211/fifo_qdisc.c      |    5 -
 net/d80211/ieee80211.c       |  276 +++++++++++++++++++++---------------------
 net/d80211/ieee80211_i.h     |   68 ++++++----
 net/d80211/ieee80211_iface.c |    8 +
 net/d80211/ieee80211_ioctl.c |   79 ++++++------
 net/d80211/ieee80211_key.h   |    7 +
 net/d80211/ieee80211_scan.c  |   12 +-
 net/d80211/ieee80211_sta.c   |  113 ++++++++---------
 net/d80211/ieee80211_sysfs.c |    6 -
 net/d80211/rate_control.c    |   18 +--
 net/d80211/rate_control.h    |    2 
 net/d80211/sta_info.c        |   31 ++---
 net/d80211/sta_info.h        |   14 +-
 net/d80211/tkip.c            |   15 --
 net/d80211/tkip.h            |    1 
 net/d80211/wep.c             |   14 +-
 net/d80211/wme.c             |   24 ++--
 net/d80211/wme.h             |   25 ----
 net/d80211/wpa.c             |   17 ---
 24 files changed, 537 insertions(+), 531 deletions(-)


-- 
Jiri Benc
SUSE Labs
