From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>
Subject: [PATCH net-next-2.6] bonding: remove useless assignment
Date: Wed, 07 Oct 2009 22:06:45 +0200
Message-ID: <4ACCF4D5.9050502@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:58674 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759991AbZJGUHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 16:07:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable old_active is first set to bond->curr_active_slave.
Then, it is unconditionally set to new_active, without being used in be=
tween.

The first assignment, having no side effect, is useless.

Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Reviewed-by: Jiri Pirko <jpirko@redhat.com>

---

Resent after fixing tab to space corruption.

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index a7e731f..fce7233 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1084,7 +1084,7 @@ static struct slave *bond_find_best_slave(struct =
bonding *bond)
	int mintime =3D bond->params.updelay;
	int i;

-	new_active =3D old_active =3D bond->curr_active_slave;
+	new_active =3D bond->curr_active_slave;

	if (!new_active) { /* there were no active slaves left */
		if (bond->slave_cnt > 0)   /* found one slave */

