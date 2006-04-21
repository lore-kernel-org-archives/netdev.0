From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/10] d80211: bugfixes and reducing number of interfaces
Date: Fri, 21 Apr 2006 22:53:19 +0200 (CEST)
Message-ID: <20060421225314.048983000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:45441 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932439AbWDUUww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:52:52 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following patches can be also obtained from:
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git master

The main purpose of these patches is to reduce the number of network
interfaces presented to userspace; there are also some important bugfixes
among them (mainly 3rd patch).


Jiri Benc:
      d80211: fix SIOCGIWESSID ioctl
      d80211: use is_multicast_ether_addr
      d80211: fix Oops caused by packets sent directly to master device
      d80211: don't use pointer in ieee80211_tx_control
      d80211: per-interface SSID
      d80211: per-interface generic_elem
      d80211: get rid of default AP interface
      d80211: get rid of default management interface
      d80211: rename master interface
      d80211: add one default interface

 include/net/d80211.h         |   35 +--
 net/d80211/ieee80211.c       |  436 ++++++++++++++++++++++++-------------------
 net/d80211/ieee80211_i.h     |   34 ++-
 net/d80211/ieee80211_iface.c |   96 ++++++++-
 net/d80211/ieee80211_ioctl.c |   95 +++++----
 net/d80211/ieee80211_proc.c  |    9 
 net/d80211/ieee80211_sta.c   |    3 
 net/d80211/ieee80211_sysfs.c |    3 
 net/d80211/wme.c             |    3 
 9 files changed, 430 insertions(+), 284 deletions(-)

-- 
Jiri Benc
SUSE Labs
