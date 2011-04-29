From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] wireless: Make and use const struct ieee80211_channel
Date: Thu, 28 Apr 2011 22:25:06 -0700
Message-ID: <cover.1304054543.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org, libertas-dev@lists.infradead.org,
	orinoco-users@lists.sourceforge.net,
	orinoco-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1094 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092Ab1D2FZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2011 01:25:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches (2):
  wireless: Make struct ieee80211_channel const where possible
  wireless: Use const struct ieee80211_channel where possible

 drivers/net/wireless/iwlegacy/iwl-4965-lib.c |    2 +-
 drivers/net/wireless/iwlegacy/iwl3945-base.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c   |    2 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c |    4 +-
 drivers/net/wireless/libertas/cfg.c          |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c      |    9 ++++---
 drivers/net/wireless/orinoco/cfg.c           |    2 +-
 drivers/net/wireless/rndis_wlan.c            |    9 ++++---
 drivers/net/wireless/wl1251/cmd.c            |    2 +-
 drivers/net/wireless/wl1251/cmd.h            |    2 +-
 include/net/cfg80211.h                       |   34 +++++++++++++-------------
 net/wireless/chan.c                          |   10 ++++----
 net/wireless/core.h                          |   14 ++++++----
 net/wireless/debugfs.c                       |    2 +-
 net/wireless/ibss.c                          |    6 ++--
 net/wireless/mlme.c                          |   15 ++++++-----
 net/wireless/nl80211.c                       |   31 ++++++++++++-----------
 net/wireless/nl80211.h                       |    9 ++++---
 net/wireless/reg.c                           |   11 ++++----
 net/wireless/reg.h                           |    4 +-
 net/wireless/scan.c                          |    6 ++--
 net/wireless/wext-sme.c                      |    2 +-
 22 files changed, 94 insertions(+), 86 deletions(-)

-- 
1.7.5.rc3.dirty

