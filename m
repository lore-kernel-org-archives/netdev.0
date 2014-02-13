From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 1/2] net: axienet: Fix compilation error
Date: Thu, 13 Feb 2014 08:10:42 +0100
Message-ID: <2082312fdbceca394080302b1709a5f71d7d3652.1392275432.git.michal.simek@xilinx.com>
References: <cover.1392275432.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-8705-1392275452-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Srikanth Thokala <sthokal@xilinx.com>,
	Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392275432.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1392275432.git.michal.simek@xilinx.com>
References: <cover.1392275432.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-8705-1392275452-0001

Add missing header to fix compilation error.
drivers/net/ethernet/xilinx/xilinx_axienet_main.c:1575:22:
 error: undefined identifier 'irq_of_parse_and_map'
drivers/net/ethernet/xilinx/xilinx_axienet_main.c:1576:22:
 error: undefined identifier 'irq_of_parse_and_map'

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

Changes in v2: None

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 1ec65fe..9fb8ab2 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -26,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/of_mdio.h>
 #include <linux/of_platform.h>
+#include <linux/of_irq.h>
 #include <linux/of_address.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
--
1.8.2.3


--=_mimegpg-monstr-desktop-8705-1392275452-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL8b/wACgkQykllyylKDCHfoQCfX6mutJlDnfLniVfFRfQkW0DK
5BkAn0Gyfiw8WvJedqXhxM3QijEgEmE7
=mr9a
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-8705-1392275452-0001--
