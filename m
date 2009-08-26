From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH] [resend] Remove useless condition: max_bonds is of type int
 and cannot be greater than INT_MAX.
Date: Wed, 26 Aug 2009 21:22:47 +0200
Message-ID: <4A958B87.1030800@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.services.sfr.fr ([93.17.128.1]:54020 "EHLO
	smtp21.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628AbZHZTWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 15:22:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove useless condition: max_bonds is of type int and cannot be greate=
r than=20
INT_MAX.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
  drivers/net/bonding/bond_main.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 4798d30..edd71a1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4755,7 +4755,7 @@ static int bond_check_params(struct bond_params *=
params)
  		params->ad_select =3D BOND_AD_STABLE;
  	}

-	if (max_bonds < 0 || max_bonds > INT_MAX) {
+	if (max_bonds < 0) {
  		pr_warning(DRV_NAME
  		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
  		       "was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",


