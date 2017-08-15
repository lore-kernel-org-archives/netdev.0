From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/4] skge: add paren around sizeof arg
Date: Tue, 15 Aug 2017 10:29:18 -0700
Message-ID: <20170815172919.26153-4-sthemmin@microsoft.com>
References: <20170815172919.26153-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: mlindner@marvell.com, stephen@networkplumber.org, mst@redhat.com,
        jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33297 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753688AbdHOR3c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 13:29:32 -0400
Received: by mail-pg0-f52.google.com with SMTP id u5so9574873pgn.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 10:29:32 -0700 (PDT)
In-Reply-To: <20170815172919.26153-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/ethernet/marvell/skge.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 5d7d94de4e00..8a835e82256a 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3516,7 +3516,7 @@ static const char *skge_board_name(const struct skge_hw *hw)
 		if (skge_chips[i].id == hw->chip_id)
 			return skge_chips[i].name;
 
-	snprintf(buf, sizeof buf, "chipid 0x%x", hw->chip_id);
+	snprintf(buf, sizeof(buf), "chipid 0x%x", hw->chip_id);
 	return buf;
 }
 
-- 
2.11.0
