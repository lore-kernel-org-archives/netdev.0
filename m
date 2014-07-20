From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 25/30] niu: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:27:50 +0200
Message-ID: <1405866475-24754-6-git-send-email-fabf@skynet.be>
References: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/sun/niu.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 79606f47a..db8ffde 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -2584,7 +2584,6 @@ static int niu_determine_phy_disposition(struct niu *np)
 				break;
 			default:
 				return -EINVAL;
-				break;
 			}
 			phy_addr_off = niu_atca_port_num[np->port];
 			break;
-- 
1.9.1
