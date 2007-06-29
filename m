From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 18/21] r8169: add endianess annotations to [RT]xDesc
Date: Fri, 29 Jun 2007 22:28:07 +0200
Message-ID: <20070629202807.GT3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46085 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753907AbXF2U2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:28:24 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1942bf7..f66ee3b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -362,15 +362,15 @@ enum desc_status_bit {
 #define RsvdMask	0x3fffc000
 
 struct TxDesc {
-	u32 opts1;
-	u32 opts2;
-	u64 addr;
+	__le32 opts1;
+	__le32 opts2;
+	__le64 addr;
 };
 
 struct RxDesc {
-	u32 opts1;
-	u32 opts2;
-	u64 addr;
+	__le32 opts1;
+	__le32 opts2;
+	__le64 addr;
 };
 
 struct ring_info {
-- 
1.4.4.2

