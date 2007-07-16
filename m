From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3/7][ATM]: [nicstar] Replace C code with call to ARRAY_SIZE() macro.
Date: Mon, 16 Jul 2007 12:30:29 -0400
Message-ID: <200707161630.l6GGUTJP009307@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:47466 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756121AbXGPREm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 13:04:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ATM]: [nicstar] Replace C code with call to ARRAY_SIZE() macro.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
Signed-off-by: chas williams <chas@cmf.nrl.navy.mil>

---
commit e9e4b3e9524fd445fcc06f56678a6b7f3d1d5f3a
tree 7edafbabdafaad229fb728c1c74e6bca60a0c58c
parent 6bab08f73e2c24665a523f15a4ebe4002be38a91
author Robert P. J. Day <rpjday@mindspring.com> Wed, 11 Jul 2007 12:23:43 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 11 Jul 2007 12:23:43 -0400

 drivers/atm/nicstarmac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/nicstarmac.c b/drivers/atm/nicstarmac.c
index 480947f..842e26c 100644
--- a/drivers/atm/nicstarmac.c
+++ b/drivers/atm/nicstarmac.c
@@ -134,7 +134,7 @@ nicstar_read_eprom_status( virt_addr_t base )
    /* Send read instruction */
    val = NICSTAR_REG_READ( base, NICSTAR_REG_GENERAL_PURPOSE ) & 0xFFFFFFF0;
 
-   for (i=0; i<sizeof rdsrtab/sizeof rdsrtab[0]; i++)
+   for (i=0; i<ARRAY_SIZE(rdsrtab); i++)
    {
 	NICSTAR_REG_WRITE( base, NICSTAR_REG_GENERAL_PURPOSE,
 		(val | rdsrtab[i]) );
