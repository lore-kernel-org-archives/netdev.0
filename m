From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: PATCH: sundance #6
Date: Thu, 19 Sep 2002 20:18:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D8A6948.5020606@mandrakesoft.com>
References: <Pine.LNX.4.44.0209190903050.29420-100000@beohost.scyld.com> <3D8A25D1.3060300@mandrakesoft.com> <3D8A433B.5010703@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070102080708090909020508"
Cc: Donald Becker <becker@scyld.com>, Jason Lunz <lunz@falooley.org>,
   Richard Gooch <rgooch@ras.ucalgary.ca>,
   "Patrick R. McManus" <mcmanus@ducksong.com>, edward_peng@dlink.com.tw
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070102080708090909020508
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The obvious sundance update from the earlier discussion...

--------------070102080708090909020508
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/sundance.c b/drivers/net/sundance.c
--- a/drivers/net/sundance.c	Thu Sep 19 20:16:23 2002
+++ b/drivers/net/sundance.c	Thu Sep 19 20:16:23 2002
@@ -60,6 +60,7 @@
 		* default to PIO, to fix chip bugs
 	- Add missing unregister_netdev (Jason Lunz)
 	- Add CONFIG_SUNDANCE_MMIO config option (jgarzik)
+	- Better rx buf size calculation (Donald Becker)
 
 */
 
@@ -973,7 +974,7 @@
 	np->cur_rx = np->cur_tx = 0;
 	np->dirty_rx = np->dirty_tx = 0;
 
-	np->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 36);
+	np->rx_buf_sz = (dev->mtu <= 1520 ? PKT_BUF_SZ : dev->mtu + 16);
 
 	/* Initialize all Rx descriptors. */
 	for (i = 0; i < RX_RING_SIZE; i++) {

--------------070102080708090909020508--
