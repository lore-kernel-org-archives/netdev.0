From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 14/16] e1000:Fix Packet Buffer Allocation
 logic for 82547_rev_2
Date: Tue, 19 Apr 2005 23:05:43 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504190433480.10641@anoushka.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix Packet Buffer Allocation logic for 82547_rev_2 controller

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-04-11 02:22:27.000000000 -0700
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-04-11 02:22:29.000000000 -0700
@@ -417,6 +417,7 @@ e1000_down(struct e1000_adapter *adapter
 
 	switch (adapter->hw.mac_type) {
 	case e1000_82547:
+	case e1000_82547_rev_2:
 		pba = E1000_PBA_30K;
 		break;
 	case e1000_82573:
