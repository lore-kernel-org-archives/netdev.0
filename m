From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/6] r8169: fix r8101 quirk dupe
Date: Tue, 11 Aug 2009 07:41:52 +0200
Message-ID: <20090811054152.GB16446@electric-eye.fr.zoreil.com>
References: <20090811054039.GA16446@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edward_hsu@realtek.com.tw, netdev@vger.kernel.org,
	plr.vincent@gmail.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60940 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750988AbZHKLvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 07:51:07 -0400
Content-Disposition: inline
In-Reply-To: <20090811054039.GA16446@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed by Vincent Pelletier <plr.vincent@gmail.com>.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b82780d..eac882b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2757,7 +2757,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	EnableBist | \
 	Mac_dbgo_oe | \
 	Force_half_dup | \
-	Force_half_dup | \
+	Force_rxflow_en | \
 	Force_txflow_en | \
 	Cxpl_dbg_sel | \
 	ASF | \
-- 
1.6.2.5

