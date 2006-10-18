From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/18] d80211: pull request
Date: Wed, 18 Oct 2006 17:49:23 +0200 (CEST)
Message-ID: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:12450 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161162AbWJRPsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:48:54 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up
to obtain following patches:

David Kimdon:
      d80211: Fix overflow when creating AVS header
      d80211: allow wireless vlan interface to have same MAC an AP interface
      d80211: use FCS_LEN instead of hardcoded number.
      d80211: silence sparse warning: bad constant expression
      d80211: remove unused Super AG definitions, purge comment

Elliot Schwartz:
      d80211: remove unused xr structure members, interface, etc.
      d80211: remove rate limit code

Jiri Benc:
      d80211: fix is_ieee80211_device
      d80211: add missing rtnl_unlock()
      d80211: del sta timer on interface close
      d80211: rename rate_control.h to ieee80211_rate.h
      d80211: proper rate_control loading
      d80211: rename rate_control.c to rc80211_simple.c
      d80211: proper rate control structures freeing
      d80211: allow changing of the rate control algorithm
      d80211: rate_control: do not use atomic allocations when not necessary

Jouni Malinen:
      d80211: retain PS frames for at least STA listen interval

Modestas Vainius:
      d80211: Fix TX/RX rates

 include/net/d80211.h             |   23 ----
 include/net/d80211_mgmt.h        |    4 -
 include/net/d80211_shared.h      |    6 -
 net/d80211/Makefile              |    3 
 net/d80211/hostapd_ioctl.h       |   10 --
 net/d80211/ieee80211.c           |  245 +++++++++++++++++---------------------
 net/d80211/ieee80211_i.h         |   11 +-
 net/d80211/ieee80211_iface.c     |   12 --
 net/d80211/ieee80211_ioctl.c     |   38 +-----
 net/d80211/ieee80211_rate.c      |  140 ++++++++++++++++++++++
 net/d80211/ieee80211_rate.h      |  161 +++++++++++++++++++++++++
 net/d80211/ieee80211_scan.c      |    4 -
 net/d80211/ieee80211_sta.c       |   19 ++-
 net/d80211/ieee80211_sysfs.c     |   27 +++-
 net/d80211/ieee80211_sysfs_sta.c |    5 -
 net/d80211/rate_control.h        |  154 ------------------------
 net/d80211/rate_control.c        |   26 ++--
 net/d80211/sta_info.c            |   46 ++++---
 net/d80211/sta_info.h            |    9 +
 19 files changed, 513 insertions(+), 430 deletions(-)

-- 
Jiri Benc
SUSE Labs
