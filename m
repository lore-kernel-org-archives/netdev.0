From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.6 7/11] ixgb: Support for ethtool -d
 (fwd)
Date: Wed, 27 Apr 2005 10:50:20 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271049560.16913-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ixgb support for ethtool -d

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ethtool.c net-drivers-2.6/=
drivers/net/ixgb.new/ixgb_ethtool.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ethtool.c=A0=A0=A0=A0 2005-04-0=
5 23:06:36.331229608 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ethtool.c 2005-04-05 23:06:=
38.037970144 -0700
@@ -252,7 +252,9 @@ ixgb_get_regs(struct net_device *netdev,
=A0=A0=A0=A0=A0=A0=A0 uint32_t *reg_start =3D reg;
=A0=A0=A0=A0=A0=A0=A0 uint8_t i;
=A0
-=A0=A0=A0=A0=A0=A0 regs->version =3D (adapter->hw.device_id << 16) | ada=
pter->hw.subsystem_id;
+=A0=A0=A0=A0=A0=A0 /* the 1 (one) below indicates an attempt at versioni=
ng, if the
+=A0=A0=A0=A0=A0=A0=A0 * interface in ethtool or the driver this 1 should=
 be incremented */
+=A0=A0=A0=A0=A0=A0 regs->version =3D (1<<24) | hw->revision_id << 16 | h=
w->device_id;
=A0
=A0=A0=A0=A0=A0=A0=A0 /* General Registers */
=A0=A0=A0=A0=A0=A0=A0 *reg++ =3D IXGB_READ_REG(hw, CTRL0);=A0=A0=A0=A0=A0=
 /*=A0=A0 0 */
