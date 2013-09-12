From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 2/2] net: emaclite: Code cleanup
Date: Thu, 12 Sep 2013 09:05:11 +0200
Message-ID: <22c8762e2e6eb8bb7d8b945b8f0a17f54e5c718c.1378969499.git.michal.simek@xilinx.com>
References: <196d8368eee2d45eeeab40e96e2971f78ed8a79b.1378969499.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-28876-1378969513-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	"David S. Miller" <davem@davemloft.net>,
	Jens Renner <renner@efe-gmbh.de>,
	Libo Chen <libo.chen@huawei.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <196d8368eee2d45eeeab40e96e2971f78ed8a79b.1378969499.git.michal.simek@xilinx.com>
In-Reply-To: <196d8368eee2d45eeeab40e96e2971f78ed8a79b.1378969499.git.michal.simek@xilinx.com>
References: <196d8368eee2d45eeeab40e96e2971f78ed8a79b.1378969499.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-28876-1378969513-0001

No function changes (s/\ \t/\t/g)

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 28 +++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index de39098..80dd404 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -31,7 +31,7 @@
 #define DRIVER_NAME "xilinx_emaclite"

 /* Register offsets for the EmacLite Core */
-#define XEL_TXBUFF_OFFSET 	0x0		/* Transmit Buffer */
+#define XEL_TXBUFF_OFFSET	0x0		/* Transmit Buffer */
 #define XEL_MDIOADDR_OFFSET	0x07E4		/* MDIO Address Register */
 #define XEL_MDIOWR_OFFSET	0x07E8		/* MDIO Write Data Register */
 #define XEL_MDIORD_OFFSET	0x07EC		/* MDIO Read Data Register */
@@ -63,13 +63,13 @@
 #define XEL_MDIOCTRL_MDIOEN_MASK  0x00000008	/* MDIO Enable */

 /* Global Interrupt Enable Register (GIER) Bit Masks */
-#define XEL_GIER_GIE_MASK	0x80000000 	/* Global Enable */
+#define XEL_GIER_GIE_MASK	0x80000000	/* Global Enable */

 /* Transmit Status Register (TSR) Bit Masks */
-#define XEL_TSR_XMIT_BUSY_MASK	 0x00000001 	/* Tx complete */
-#define XEL_TSR_PROGRAM_MASK	 0x00000002 	/* Program the MAC address */
-#define XEL_TSR_XMIT_IE_MASK	 0x00000008 	/* Tx interrupt enable bit */
-#define XEL_TSR_XMIT_ACTIVE_MASK 0x80000000 	/* Buffer is active, SW bit
+#define XEL_TSR_XMIT_BUSY_MASK	 0x00000001	/* Tx complete */
+#define XEL_TSR_PROGRAM_MASK	 0x00000002	/* Program the MAC address */
+#define XEL_TSR_XMIT_IE_MASK	 0x00000008	/* Tx interrupt enable bit */
+#define XEL_TSR_XMIT_ACTIVE_MASK 0x80000000	/* Buffer is active, SW bit
 						 * only. This is not documented
 						 * in the HW spec */

@@ -77,21 +77,21 @@
 #define XEL_TSR_PROG_MAC_ADDR	(XEL_TSR_XMIT_BUSY_MASK | XEL_TSR_PROGRAM_MASK)

 /* Receive Status Register (RSR) */
-#define XEL_RSR_RECV_DONE_MASK	0x00000001 	/* Rx complete */
-#define XEL_RSR_RECV_IE_MASK	0x00000008 	/* Rx interrupt enable bit */
+#define XEL_RSR_RECV_DONE_MASK	0x00000001	/* Rx complete */
+#define XEL_RSR_RECV_IE_MASK	0x00000008	/* Rx interrupt enable bit */

 /* Transmit Packet Length Register (TPLR) */
-#define XEL_TPLR_LENGTH_MASK	0x0000FFFF 	/* Tx packet length */
+#define XEL_TPLR_LENGTH_MASK	0x0000FFFF	/* Tx packet length */

 /* Receive Packet Length Register (RPLR) */
-#define XEL_RPLR_LENGTH_MASK	0x0000FFFF 	/* Rx packet length */
+#define XEL_RPLR_LENGTH_MASK	0x0000FFFF	/* Rx packet length */

-#define XEL_HEADER_OFFSET	12 		/* Offset to length field */
-#define XEL_HEADER_SHIFT	16 		/* Shift value for length */
+#define XEL_HEADER_OFFSET	12		/* Offset to length field */
+#define XEL_HEADER_SHIFT	16		/* Shift value for length */

 /* General Ethernet Definitions */
-#define XEL_ARP_PACKET_SIZE		28 	/* Max ARP packet size */
-#define XEL_HEADER_IP_LENGTH_OFFSET	16 	/* IP Length Offset */
+#define XEL_ARP_PACKET_SIZE		28	/* Max ARP packet size */
+#define XEL_HEADER_IP_LENGTH_OFFSET	16	/* IP Length Offset */



--
1.8.2.3


--=_mimegpg-monstr-desktop-28876-1378969513-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlIxZ6kACgkQykllyylKDCHAPwCffRkJYEoiSdtGsNGMIHigwKoK
AmIAn26iM8TaSgOFhidyagO72+LQbWEY
=3rHa
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-28876-1378969513-0001--
