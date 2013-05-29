From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 08/11] net: emaclite: Let's make xemaclite_adjust_link static
Date: Wed, 29 May 2013 17:33:08 +0200
Message-ID: <a54726b8a2076eaf085673e4530ea9a2ac4eec5c.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-27643-1369841615-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
In-Reply-To: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
References: <131c9262c3094ee3c664bd729a66e0709ceae82c.1369841519.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-27643-1369841615-0001

xemaclite_adjust_link is used locally.
It removes sparse warning:
drivers/net/ethernet/xilinx/xilinx_emaclite.c:916:6: warning:
symbol 'xemaclite_adjust_link' was not declared. Should it be static?

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
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


--=_mimegpg-monstr-desktop-27643-1369841615-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGmH88ACgkQykllyylKDCFW4ACfS4Ly83V3KrmYceiG9T71USeB
2z4AniFkzHyNZ93T68p1yHfaa60NWpYX
=Ul8g
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-27643-1369841615-0001--
