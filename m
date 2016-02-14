From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] ravb: kill useless *switch* defaults
Date: Sun, 14 Feb 2016 22:56:03 +0300
Message-ID: <42828566.vpINptsK4T@wasted.cogentembedded.com>
References: <2504091.pf4fyK11eg@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <2504091.pf4fyK11eg@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The  driver has the *default* case doing nothing in the *switch* statement
with an integer expression -- remove it.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/ravb_main.c |    2 --
 1 file changed, 2 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net-next/drivers/net/ethernet/renesas/ravb_main.c
@@ -92,8 +92,6 @@ static void ravb_set_rate(struct net_dev
 	case 1000:		/* 1000BASE */
 		ravb_write(ndev, GECMR_SPEED_1000, GECMR);
 		break;
-	default:
-		break;
 	}
 }
 
