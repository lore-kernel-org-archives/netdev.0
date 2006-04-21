From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/17] d80211 patches
Date: Fri, 21 Apr 2006 22:11:31 +0200 (CEST)
Message-ID: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:9351 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932397AbWDUULF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:05 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

please pull to your wireless-dev tree from

git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up

to obtain following patches. They were all posted to netdev previously and
are all discussed with Jouni (except 7th patch, but that is quite simple and
shouldn't cause any harm).

Also, the new rule of required kerneldoc documentation is hopefully
fulfilled - the only exception is ieee80211_hw structure, which is
well-commented but with comments inside. I think it will be best to convert
comments in ieee80211_hw by a separate patch.

Please note that these changes break d80211 drivers.

Jiri Benc:
      d80211: symlinks to wiphy in sysfs
      d80211: allow WDS remote to by set by WE
      d80211: add IBSS and monitor interface types
      d80211: non-shared interface types
      d80211: remove local->bssid variable
      d80211: rename IEEE80211_SUB_IF_TYPE_ constants
      d80211: ask driver for allowed iface combinations
      d80211: remove obsolete stuff
      d80211: fix interface configuration
      d80211: rename adm_status to radio_enabled
      d80211: interface types changeable by SIOCSIWMODE
      d80211: master interface auto up/down
      d80211: set_multicast_list
      d80211: fix handling of received frames
      d80211: fix monitor interfaces
      d80211: fix AP interfaces

Jouni Malinen:
      d80211: Replace MODULE_PARM with module_param

 include/net/d80211.h         |  179 ++++-
 net/d80211/Makefile          |    1 
 net/d80211/hostapd_ioctl.h   |    3 
 net/d80211/ieee80211.c       | 1473 +++++++++++++++----------------------------
 net/d80211/ieee80211_dev.c   |   16 
 net/d80211/ieee80211_i.h     |   80 +-
 net/d80211/ieee80211_iface.c |  299 ++++++++
 net/d80211/ieee80211_ioctl.c |  468 ++++++-------
 net/d80211/ieee80211_proc.c  |   34 
 net/d80211/ieee80211_sta.c   |  109 +--
 net/d80211/ieee80211_sysfs.c |   95 +-
 net/d80211/wme.c             |    3 
 12 files changed, 1376 insertions(+), 1384 deletions(-)

Jiri Benc
SUSE Labs
