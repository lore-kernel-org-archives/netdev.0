From: Roland Dreier <roland@kernel.org>
Subject: [PATCH] be2net: Remove unused OFFSET_IN_PAGE() macro
Date: Wed, 29 Feb 2012 22:40:46 -0800
Message-ID: <1330584046-3938-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
To: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog114.obsmtp.com ([74.125.245.96]:36636 "HELO
	na3sys010aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753503Ab2CAGkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 01:40:53 -0500
Received: by mail-pw0-f52.google.com with SMTP id um15so655848pbc.11
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 22:40:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@purestorage.com>

Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index cbdec25..cca5c0e 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -428,10 +428,6 @@ extern const struct ethtool_ops be_ethtool_ops;
 		((u32)((((size_t)(_address) & (PAGE_SIZE_4K - 1)) + 	\
 			(size) + (PAGE_SIZE_4K - 1)) >> PAGE_SHIFT_4K))
 
-/* Byte offset into the page corresponding to given address */
-#define OFFSET_IN_PAGE(addr)						\
-		 ((size_t)(addr) & (PAGE_SIZE_4K-1))
-
 /* Returns bit offset within a DWORD of a bitfield */
 #define AMAP_BIT_OFFSET(_struct, field)  				\
 		(((size_t)&(((_struct *)0)->field))%32)
-- 
1.7.9
