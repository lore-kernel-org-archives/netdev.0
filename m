From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH] be2net: Fix CQE_STATUS_EXTD_SHIFT define
Date: Fri, 6 Nov 2009 12:47:46 +0530
Message-ID: <20091106071746.GA27296@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:22084 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750970AbZKFHRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 02:17:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 4995378..e5f9676 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -68,7 +68,7 @@ enum {
 #define CQE_STATUS_COMPL_MASK		0xFFFF
 #define CQE_STATUS_COMPL_SHIFT		0	/* bits 0 - 15 */
 #define CQE_STATUS_EXTD_MASK		0xFFFF
-#define CQE_STATUS_EXTD_SHIFT		0	/* bits 0 - 15 */
+#define CQE_STATUS_EXTD_SHIFT		16	/* bits 16 - 31 */
 
 struct be_mcc_compl {
 	u32 status;		/* dword 0 */
-- 
1.6.3.3

