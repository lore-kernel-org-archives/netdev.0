From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] sfc: Remove preprocessor condition from register
 table definitions
Date: Thu, 7 Nov 2013 19:58:43 +0000
Message-ID: <1383854323.3802.12.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36888 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164Ab3KGT6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 14:58:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This condition was mistakenly copied from the corresponding
definitions in the out-of-tree version of sfc.  It has no effect here.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I've applied this change just after the 3.12 tag.

Ben.

 sfc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/sfc.c b/sfc.c
index 1bb3689..9478b38 100644
--- a/sfc.c
+++ b/sfc.c
@@ -3739,9 +3739,7 @@ static const struct efx_nic_reg_table efx_nic_reg_tables[] = {
 	REGISTER_TABLE_CZ(MC_TREG_SMEM),
 	/* MSIX_PBA_TABLE is not mapped */
 	/* SRM_DBG is not mapped (and is redundant with BUF_FLL_TBL) */
-#if !defined(EFX_USE_KCOMPAT) || defined(EFX_HAVE_VMALLOC_REG_DUMP_BUF)
 	REGISTER_TABLE_BZ(RX_FILTER_TBL0),
-#endif
 	REGISTER_TABLE_DZ(BIU_MC_SFT_STATUS),
 };
 
-- 
1.8.1.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
