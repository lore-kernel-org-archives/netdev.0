From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/14] d80211: pull request
Date: Wed, 27 Sep 2006 17:50:44 +0200 (CEST)
Message-ID: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:47500 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964962AbWI0Ptk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:40 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up
to obtain following patches:

David Kimdon:
      d80211: fix multiple device ap support
      d80211: Fix type of prism2_hostapd_param crypt.alg
      d80211: allow vlan interfaces to receive ToDS frames

Hong Liu:
      d80211: fix wpa_supplicant reassoc problem
      d80211: add hardware scan callback
      d80211: fix "iwconfig key [x]" behavior

Jiri Benc:
      d80211: fix invalid pointer dereference

Johannes Berg:
      d80211: use BUILD_BUG_ON
      d80211: clean up those huge else if statements
      d80211: use list_for_each_entry{,_safe}
      d80211: LED triggers

Michael Wu:
      d80211: fix WEP on big endian cpus

Mohamed Abbas:
      d80211: diplay supported rates in readable format
      d80211: getting wrong freq value if we did hardware scan

 include/net/d80211.h         |   46 ++++++++++++++----
 net/d80211/Kconfig           |    9 ++++
 net/d80211/Makefile          |   10 ++--
 net/d80211/hostapd_ioctl.h   |    2 -
 net/d80211/ieee80211.c       |   73 ++++++++++------------------
 net/d80211/ieee80211_dev.c   |    7 +--
 net/d80211/ieee80211_i.h     |    6 ++
 net/d80211/ieee80211_iface.c |    2 -
 net/d80211/ieee80211_ioctl.c |  108 +++++++++++++++++++++---------------------
 net/d80211/ieee80211_led.c   |   93 ++++++++++++++++++++++++++++++------
 net/d80211/ieee80211_led.h   |   32 ++++++++++++
 net/d80211/ieee80211_sta.c   |  107 +++++++++++++++++++++++-------------------
 net/d80211/sta_info.c        |   26 +++++-----
 net/d80211/wep.c             |   10 ++--
 14 files changed, 324 insertions(+), 207 deletions(-)

-- 
Jiri Benc
SUSE Labs
