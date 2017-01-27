From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net: ethernet: aquantia: remove another redundant err check
Date: Fri, 27 Jan 2017 15:00:25 +0000
Message-ID: <20170127150025.18886-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>,
        David VomLehn <vomlehn@texas.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:37984 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932164AbdA0Phf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:37:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The check on err < 0 is redundant and can be removed. Detected
by CoverityScan, CID#1398318 ("Logically Dead Code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index b517b26..817c145 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -304,8 +304,6 @@ int aq_ring_rx_fill(struct aq_ring_s *self)
 
 		buff = NULL;
 	}
-	if (err < 0)
-		goto err_exit;
 
 err_exit:
 	if (err < 0) {
-- 
2.10.2
