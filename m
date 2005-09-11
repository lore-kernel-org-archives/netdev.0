From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH  2/12] Add more AX.25 PIDs
Date: Sun, 11 Sep 2005 23:18:44 +0100
Message-ID: <20050911221844.GA9280@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a few more PID definitions.  AX.25 PIDs are the equivalent to IP
protocol numbers.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 include/net/ax25.h |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

Index: linux-cvs/include/net/ax25.h
===================================================================
--- linux-cvs.orig/include/net/ax25.h
+++ linux-cvs/include/net/ax25.h
@@ -26,11 +26,20 @@
 
 /* AX.25 Protocol IDs */
 #define AX25_P_ROSE			0x01
-#define AX25_P_IP			0xCC
-#define AX25_P_ARP			0xCD
-#define AX25_P_TEXT 			0xF0
-#define AX25_P_NETROM 			0xCF
-#define	AX25_P_SEGMENT			0x08
+#define AX25_P_VJCOMP			0x06	/* Compressed TCP/IP packet   */
+						/* Van Jacobsen (RFC 1144)    */
+#define AX25_P_VJUNCOMP			0x07	/* Uncompressed TCP/IP packet */
+						/* Van Jacobsen (RFC 1144)    */
+#define	AX25_P_SEGMENT			0x08	/* Segmentation fragment      */
+#define AX25_P_TEXNET			0xc3	/* TEXTNET datagram protocol  */
+#define AX25_P_LQ			0xc4	/* Link Quality Protocol      */
+#define AX25_P_ATALK			0xca	/* Appletalk                  */
+#define AX25_P_ATALK_ARP		0xcb	/* Appletalk ARP              */
+#define AX25_P_IP			0xcc	/* ARPA Internet Protocol     */
+#define AX25_P_ARP			0xcd	/* ARPA Adress Resolution     */
+#define AX25_P_FLEXNET			0xce	/* FlexNet                    */
+#define AX25_P_NETROM 			0xcf	/* NET/ROM                    */
+#define AX25_P_TEXT 			0xF0	/* No layer 3 protocol impl.  */
 
 /* AX.25 Segment control values */
 #define	AX25_SEG_REM			0x7F
