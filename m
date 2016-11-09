From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v9 1/8] thunderbolt: Macro rename
Date: Wed,  9 Nov 2016 16:20:01 +0200
Message-ID: <1478701208-4585-2-git-send-email-amir.jer.levy@intel.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35259 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753735AbcKIMVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 07:21:09 -0500
In-Reply-To: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This first patch updates the NHI Thunderbolt controller registers file to
reflect that it is not only for Cactus Ridge.
No functional change intended.

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
Signed-off-by: Andreas Noever <andreas.noever@gmail.com>
---
 drivers/thunderbolt/nhi_regs.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/thunderbolt/nhi_regs.h b/drivers/thunderbolt/nhi_regs.h
index 86b996c..75cf069 100644
--- a/drivers/thunderbolt/nhi_regs.h
+++ b/drivers/thunderbolt/nhi_regs.h
@@ -1,11 +1,11 @@
 /*
- * Thunderbolt Cactus Ridge driver - NHI registers
+ * Thunderbolt driver - NHI registers
  *
  * Copyright (c) 2014 Andreas Noever <andreas.noever@gmail.com>
  */
 
-#ifndef DSL3510_REGS_H_
-#define DSL3510_REGS_H_
+#ifndef NHI_REGS_H_
+#define NHI_REGS_H_
 
 #include <linux/types.h>
 
-- 
2.7.4
