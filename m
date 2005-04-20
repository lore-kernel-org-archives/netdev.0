From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 11/16] e1000:Removed redundant statement in
 e1000_clean_tx_irq
Date: Tue, 19 Apr 2005 23:05:25 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504190430240.10641@anoushka.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removed redundant statement in e1000_clean_tx_irq

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-04-11 02:22:27.000000000 -0700
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-04-11 02:22:29.000000000 -0700
@@ -2436,7 +2436,6 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			tx_desc->lower.data = 0;
 			tx_desc->upper.data = 0;
 
-			cleaned = (i == eop);
 			if(unlikely(++i == tx_ring->count)) i = 0;
 		}
 		
