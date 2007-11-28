From: =?us-ascii?Q?=3D=3Futf-8=3Fq=3FFerenc=5FW=3DC3=3DA1gner=3F=3D?=
	<wferi@niif.hu>
Subject: [PATCH 3/3] net/bonding: Purely cosmetic: rename a local variable.
Date: Wed, 28 Nov 2007 01:54:21 +0100
Message-ID: <87sl2rjiki.fsf@szonett.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, wferi@niif.hu
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:45417 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759385AbXK1AyW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 19:54:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Code for rendering multivalue sysfs files occurs three times
in this module.  Rename 'buffer' to 'buf' in the first, for
the sake of consistency.

Signed-off-by: Ferenc W=C3=A1gner <wferi@niif.hu>
---
 drivers/net/bonding/bond_sysfs.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bon=
d_sysfs.c
index 6bb91e2..5c31f5c 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -74,7 +74,7 @@ struct rw_semaphore bonding_rwsem;
  * "show" function for the bond_masters attribute.
  * The class parameter is ignored.
  */
-static ssize_t bonding_show_bonds(struct class *cls, char *buffer)
+static ssize_t bonding_show_bonds(struct class *cls, char *buf)
 {
 	int res =3D 0;
 	struct bonding *bond;
@@ -86,13 +86,12 @@ static ssize_t bonding_show_bonds(struct class *cls=
, char *buffer)
 			/* not enough space for another interface name */
 			if ((PAGE_SIZE - res) > 10)
 				res =3D PAGE_SIZE - 10;
-			res +=3D sprintf(buffer + res, "++more++ ");
+			res +=3D sprintf(buf + res, "++more++ ");
 			break;
 		}
-		res +=3D sprintf(buffer + res, "%s ",
-			       bond->dev->name);
+		res +=3D sprintf(buf + res, "%s ", bond->dev->name);
 	}
-	if (res) buffer[res-1] =3D '\n'; /* eat the leftover space */
+	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
 	up_read(&(bonding_rwsem));
 	return res;
 }
--=20
1.4.4.4

