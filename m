From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH REPOST net-next-2.6 3/4] bonding: Fix useless test: int > INT_MAX
Date: Fri, 28 Aug 2009 16:18:34 -0700
Message-ID: <23655.1251501514@death.nxdomain.ibm.com>
References: <1251497115-16234-2-git-send-email-fubar@us.ibm.com> <1251497115-16234-3-git-send-email-fubar@us.ibm.com> <1251497115-16234-4-git-send-email-fubar@us.ibm.com> <20090828.154911.197007102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nicolas.2p.debian@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:48363 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750882AbZH1XSe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 19:18:34 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7SNISZ9018410
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 19:18:28 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SNIaTZ246234
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 19:18:36 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7SNIa3t007107
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 19:18:36 -0400
In-reply-to: <20090828.154911.197007102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Jay Vosburgh <fubar@us.ibm.com>
>Date: Fri, 28 Aug 2009 15:05:14 -0700
>
>> From: Nicolas de Peslo=C3=83=C2=BCan <nicolas.2p.debian@free.fr>
>>=20
>> max_bonds is of type int and cannot be greater than INT_MAX.
>>=20
>> Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>
>It seems you use two different encodings here for Nicolas's
>last name, and thus the two-dotted 'u' comes out corrupted
>in the From: field.
>
>This causes patchwork to not be able to parse the patch
>and thus put it properly into the queue.  So all that's
>in there are patches #1, #2 and #4.

	Hmm.  Does this one work any better?  I just copied the
Signed-off-by text into the From: line.

	-J


=46rom: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
Date: Sat, 22 Aug 2009 14:17:21 +0200
Subject: [PATCH REPOST net-next-2.6 3/4] bonding: Fix useless test: int=
 > INT_MAX
MIME-Version: 1.0
Content-Type: text/plain; charset=3Dutf-8
Content-Transfer-Encoding: 8bit

max_bonds is of type int and cannot be greater than INT_MAX.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
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



---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
