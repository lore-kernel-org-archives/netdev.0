From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH] Fix useless test: int > INT_MAX
Date: Sat, 22 Aug 2009 14:17:21 +0200
Message-ID: <4A8FE1D1.1030506@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cyril Chaboisseau <cyril.chaboisseau@free.fr>
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp22.services.sfr.fr ([93.17.128.11]:62768 "EHLO
	smtp22.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755807AbZHVMR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2009 08:17:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

max_bonds is of type int and cannot be greater than INT_MAX.

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

