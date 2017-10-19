From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH net 1/5] net/ncsi: Fix AEN HNCDSC packet length
Date: Thu, 19 Oct 2017 13:43:05 +1100
Message-ID: <20171019024309.13628-1-sam@mendozajonas.com>
Cc: Samuel Mendoza-Jonas <sam@mendozajonas.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct the value of the HNCDSC AEN packet.
Fixes: 7a82ecf4cfb85 "net/ncsi: NCSI AEN packet handler"

Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
---
 net/ncsi/ncsi-aen.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ncsi/ncsi-aen.c b/net/ncsi/ncsi-aen.c
index 6898e7229285..f135938bf781 100644
--- a/net/ncsi/ncsi-aen.c
+++ b/net/ncsi/ncsi-aen.c
@@ -187,7 +187,7 @@ static struct ncsi_aen_handler {
 } ncsi_aen_handlers[] = {
 	{ NCSI_PKT_AEN_LSC,    12, ncsi_aen_handler_lsc    },
 	{ NCSI_PKT_AEN_CR,      4, ncsi_aen_handler_cr     },
-	{ NCSI_PKT_AEN_HNCDSC,  4, ncsi_aen_handler_hncdsc }
+	{ NCSI_PKT_AEN_HNCDSC,  8, ncsi_aen_handler_hncdsc }
 };
 
 int ncsi_aen_handler(struct ncsi_dev_priv *ndp, struct sk_buff *skb)
-- 
2.14.2
