From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next v2 0/4] use reset to set header pointers
Date: Thu,  3 Mar 2016 01:16:53 +0000
Message-ID: <1456967817-7632-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, kvalo@codeaurora.org,
	johannes@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9342 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbcCCBP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 20:15:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series replace set function with reset when offset is zero.

Changes since v1:
- fix typo in commit message


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
