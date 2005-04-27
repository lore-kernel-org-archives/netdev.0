From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.4 5/16] e1000:Fix kernel panic with
 82541 LOM (fwd)
Date: Wed, 27 Apr 2005 11:04:35 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271104140.17397-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix kernel panic with 82541 LOM when using a 100M cable

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/d=
rivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c=A0=A0=A0=A0=A0 2005-04=
-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c=A0 2005-04-12 23:0=
0:55.000000000 -0700
@@ -369,6 +369,7 @@ e1000_down(struct e1000_adapter *adapter
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 e1000_read_phy_reg(&adapter->=
hw, PHY_CTRL, &mii_reg);
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 mii_reg |=3D MII_CR_POWER_DOW=
N;
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 e1000_write_phy_reg(&adapter-=
>hw, PHY_CTRL, mii_reg);
+=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 mdelay(1);
=A0=A0=A0=A0=A0=A0=A0 }
=A0}
=A0
