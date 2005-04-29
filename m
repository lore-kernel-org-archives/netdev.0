From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 3/11] ixgb: Change RDT write bump
 size to 4
Date: Thu, 28 Apr 2005 18:48:06 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281846541.28003-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change RDT write bump size back to 4

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb.h net-drivers-2.6/drivers/net/ixgb.new/ixgb.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb.h	2005-04-05 23:06:36.331229608 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb.h	2005-04-05 23:06:38.056967256 -0700
@@ -110,7 +110,7 @@ struct ixgb_adapter;
 #define IXGB_TX_QUEUE_WAKE 16
 
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
-#define IXGB_RX_BUFFER_WRITE	16	/* Must be power of 2 */
+#define IXGB_RX_BUFFER_WRITE	4	/* Must be power of 2 */
 
 /* only works for sizes that are powers of 2 */
 #define IXGB_ROUNDUP(i, size) ((i) = (((i) + (size) - 1) & ~((size) - 1)))
