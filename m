From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] Fix useless test: int > INT_MAX
Date: Fri, 28 Aug 2009 14:57:51 -0700
Message-ID: <1251496672-14498-4-git-send-email-fubar@us.ibm.com>
References: <1251496672-14498-1-git-send-email-fubar@us.ibm.com>
 <1251496672-14498-2-git-send-email-fubar@us.ibm.com>
 <1251496672-14498-3-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	=?utf-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:47192 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbZH1V5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 17:57:54 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7SLu9k2029228
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:56:09 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SLvscN191394
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:57:54 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7SLvss2011644
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 15:57:54 -0600
In-Reply-To: <1251496672-14498-3-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>

max_bonds is of type int and cannot be greater than INT_MAX.

Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index ed00ba9..6b9f15b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4759,7 +4759,7 @@ static int bond_check_params(struct bond_params *=
params)
 		params->ad_select =3D BOND_AD_STABLE;
 	}
=20
-	if (max_bonds < 0 || max_bonds > INT_MAX) {
+	if (max_bonds < 0) {
 		pr_warning(DRV_NAME
 		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
 		       "was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
--=20
1.6.0.2

