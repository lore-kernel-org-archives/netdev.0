From: =?utf-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH netnext-2.6] bonding: fix a parameter name in error message
Date: Wed,  7 Oct 2009 22:59:27 +0200
Message-ID: <1254949168-12404-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: fubar@us.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:34659 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934361AbZJGVAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 17:00:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When parsing module parameters, bond_check_params() erroneously use 'xo=
r_mode'
as the name of a module parameter in an error message.

The right name for this parameter is 'xmit_hash_policy'.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 drivers/net/bonding/bond_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 69c5b15..20dc5a2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4665,7 +4665,8 @@ static int bond_check_params(struct bond_params *=
params)
 		if ((bond_mode !=3D BOND_MODE_XOR) &&
 		    (bond_mode !=3D BOND_MODE_8023AD)) {
 			pr_info(DRV_NAME
-			       ": xor_mode param is irrelevant in mode %s\n",
+				": xmit_hash_policy param is irrelevant in"
+				" mode %s\n",
 			       bond_mode_name(bond_mode));
 		} else {
 			xmit_hashtype =3D bond_parse_parm(xmit_hash_policy,
--=20
1.6.3.3

