From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/13]: mac80211: Temporarily mark QoS support BROKEN.
Date: Thu, 10 Jul 2008 03:56:40 -0700 (PDT)
Message-ID: <20080710.035640.06557826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60713
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753246AbYGJK4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:56:40 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B0AE1C8C180
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 03:56:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We will undo this after a few changsets.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/mac80211/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index d203841..10579de 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -15,6 +15,7 @@ config MAC80211_QOS
 	def_bool y
 	depends on MAC80211
 	depends on NET_SCHED
+	depends on BROKEN
 
 comment "QoS/HT support disabled"
 	depends on MAC80211 && !MAC80211_QOS
-- 
1.5.6.2.255.gbed62

