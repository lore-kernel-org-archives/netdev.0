From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH 1/3] r8169: tx checksuming default enablement
Date: Wed, 16 Feb 2005 18:23:40 -0600
Message-ID: <200502161823.40109.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Trivial enablement of transmit checksumming by default.

Originally sent on 10/28/04.  Applies cleanly to linux-2.6.11-rc2-mm2 version of the driver.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- drivers/net/r8169.c.orig 2005-01-11 17:05:58.000000000 -0600
+++ drivers/net/r8169.c 2005-02-16 17:16:19.000000000 -0600
@@ -1341,6 +1341,8 @@ rtl8169_init_one(struct pci_dev *pdev, c
  dev->poll_controller = rtl8169_netpoll;
 #endif
 
+ dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
+
  tp->intr_mask = 0xffff;
  tp->pci_dev = pdev;
  tp->mmio_addr = ioaddr;
