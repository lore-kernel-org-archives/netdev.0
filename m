From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>
Subject: [PATCH net-next-2.6] bonding: fix a parameter name in error message
Date: Mon, 05 Oct 2009 22:11:47 +0200
Message-ID: <4ACA5303.1000101@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:45168 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753430AbZJEUMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 16:12:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When parsing module parameters, bond_check_params() erroneously use 'xo=
r_mode'
as the name of a module parameter in an error message.

The right name for this parameter is 'xmit_hash_policy'.

Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

---

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 69c5b15..e061c86 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4665,7 +4665,8 @@ static int bond_check_params(struct bond_params *=
params)
                 if ((bond_mode !=3D BOND_MODE_XOR) &&
                     (bond_mode !=3D BOND_MODE_8023AD)) {
                         pr_info(DRV_NAME
-                              ": xor_mode param is irrelevant in mode =
%s\n",
+                              ": xmit_hash_policy param is irrelevant =
in"
+                              " mode %s\n",
                                bond_mode_name(bond_mode));
                 } else {
                         xmit_hashtype =3D bond_parse_parm(xmit_hash_po=
licy,
