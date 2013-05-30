From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 3/6] net: emaclite: Let's make xemaclite_adjust_link static
Date: Thu, 30 May 2013 12:28:05 +0200
Message-ID: <f8cc399b5ffff2314210c31e4d5040ca83129086.1369909618.git.michal.simek@xilinx.com>
References: <cover.1369909618.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-5461-1369909695-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>, renner@efe-gmbh.de,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1369909618.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1369909618.git.michal.simek@xilinx.com>
References: <cover.1369909618.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-5461-1369909695-0001

xemaclite_adjust_link is used locally.
It removes sparse warning:
drivers/net/ethernet/xilinx/xilinx_emaclite.c:916:6: warning:
symbol 'xemaclite_adjust_link' was not declared. Should it be static?

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
Changes in v2: None

 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index fcd1e0b..93bb14e 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -913,7 +913,7 @@ err_register:
  * There's nothing in the Emaclite device to be configured when the link
  * state changes. We just print the status.
  */
-void xemaclite_adjust_link(struct net_device *ndev)
+static void xemaclite_adjust_link(struct net_device *ndev)
 {
 	struct net_local *lp = netdev_priv(ndev);
 	struct phy_device *phy = lp->phy_dev;
--
1.8.2.3


--=_mimegpg-monstr-desktop-5461-1369909695-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGnKb8ACgkQykllyylKDCGNqgCfcL058oZNwap+O5tcMNCkRN1T
DBsAoIyl+la0xnT+uLV7o+z/slkxocsf
=qZrC
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-5461-1369909695-0001--
