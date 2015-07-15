From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bonding: trivial: remove unused variables
Date: Wed, 15 Jul 2015 16:31:09 +0200
Message-ID: <1436970669-31169-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:34621 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbbGOObW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 10:31:22 -0400
Received: by wgkl9 with SMTP id l9so35252890wgk.1
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 07:31:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Get rid of these:
drivers/net/bonding//bond_main.c: In function =E2=80=98bond_update_slav=
e_arr=E2=80=99:
drivers/net/bonding//bond_main.c:3754:6: warning: variable
=E2=80=98slaves_in_agg=E2=80=99 set but not used [-Wunused-but-set-vari=
able]
  int slaves_in_agg;
      ^
  CC [M]  drivers/net/bonding//bond_3ad.o
drivers/net/bonding//bond_3ad.c: In function
=E2=80=98ad_marker_response_received=E2=80=99:
drivers/net/bonding//bond_3ad.c:1870:61: warning: parameter =E2=80=98ma=
rker=E2=80=99
set but not used [-Wunused-but-set-parameter]
 static void ad_marker_response_received(struct bond_marker *marker,
                                                             ^
drivers/net/bonding//bond_3ad.c:1871:19: warning: parameter =E2=80=98po=
rt=E2=80=99 set
but not used [-Wunused-but-set-parameter]
      struct port *port)
                   ^

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/bonding/bond_3ad.c  | 2 --
 drivers/net/bonding/bond_main.c | 2 --
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_=
3ad.c
index 7fde4d5c2b28..3c45358844eb 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1870,8 +1870,6 @@ static void ad_marker_info_received(struct bond_m=
arker *marker_info,
 static void ad_marker_response_received(struct bond_marker *marker,
 					struct port *port)
 {
-	marker =3D NULL;
-	port =3D NULL;
 	/* DO NOTHING, SINCE WE DECIDED NOT TO IMPLEMENT THIS FEATURE FOR NOW=
 */
 }
=20
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 317a49480475..1c6a773c87ea 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3751,7 +3751,6 @@ int bond_update_slave_arr(struct bonding *bond, s=
truct slave *skipslave)
 	struct slave *slave;
 	struct list_head *iter;
 	struct bond_up_slave *new_arr, *old_arr;
-	int slaves_in_agg;
 	int agg_id =3D 0;
 	int ret =3D 0;
=20
@@ -3782,7 +3781,6 @@ int bond_update_slave_arr(struct bonding *bond, s=
truct slave *skipslave)
 			}
 			goto out;
 		}
-		slaves_in_agg =3D ad_info.ports;
 		agg_id =3D ad_info.aggregator_id;
 	}
 	bond_for_each_slave(bond, slave, iter) {
--=20
1.9.3
