From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 0/4] use reset to set header pointers
Date: Tue,  1 Mar 2016 09:27:34 +0000
Message-ID: <1456824458-19499-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, kvalo@codeaurora.org,
	johannes@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8830 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbcCAJ0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 04:26:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series replace set function with reset when offset is zero.

Zhang Shengju (4):
  vxlan: use reset to set header pointers
  mac80211_hwsim: use reset to set mac header
  mac80211: use reset to set header pointer
  wireless: use reset to set mac header

 drivers/net/vxlan.c                   | 6 +++---
 drivers/net/wireless/mac80211_hwsim.c | 4 ++--
 net/mac80211/mesh_hwmp.c              | 6 +++---
 net/mac80211/rx.c                     | 2 +-
 net/mac80211/status.c                 | 2 +-
 net/mac80211/tx.c                     | 8 ++++----
 net/wireless/util.c                   | 2 +-
 7 files changed, 15 insertions(+), 15 deletions(-)

-- 
1.8.3.1
