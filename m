From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/12] d80211: pull request
Date: Wed,  3 Jan 2007 19:05:07 +0100 (CET)
Message-ID: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42218 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751013AbXACSFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:09 -0500
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up2
to obtain following patches:

David Kimdon:
      d80211: clear ifsta->associated flag when authentication starts
      d80211: inhibit duplicate authentication requests when setting bssid

Jan Kiszka:
      d80211: Reinit keys on mode change

Jiri Benc:
      d80211: simplify classify_1d
      d80211: small documentation fix
      d80211: do not cancel uninitialized work

Johannes Berg:
      d80211: add missing \n in skb queue warning

Michael Buesch:
      d80211: Fix passing of invalid pointer
      d80211: Fix 64bit printk warnings
      d80211: Turn PHYmode list from an array into a linked list
      d80211: constify ieee80211_ops pointer

Zhu Yi:
      d80211: fix classify_1d() priority selection

 include/net/d80211.h         |   31 +++++++--------
 net/d80211/ieee80211.c       |   89 +++++++++++++++++-------------------------
 net/d80211/ieee80211_i.h     |    9 +++-
 net/d80211/ieee80211_iface.c |    5 +-
 net/d80211/ieee80211_ioctl.c |   69 ++++++++++++++++-----------------
 net/d80211/ieee80211_scan.c  |   83 ++++++++++++++++++---------------------
 net/d80211/ieee80211_sta.c   |   55 +++++++++++++++-----------
 net/d80211/ieee80211_sysfs.c |   10 ++---
 net/d80211/wme.c             |   19 +--------
 9 files changed, 170 insertions(+), 200 deletions(-)


-- 
Jiri Benc
SUSE Labs
