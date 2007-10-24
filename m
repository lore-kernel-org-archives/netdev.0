From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport softnet_data
Date: Wed, 24 Oct 2007 18:24:25 +0200
Message-ID: <20071024162425.GI30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:33387 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759407AbXJXQX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 12:23:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The EXPORT_PER_CPU_SYMBOL(softnet_data) is no longer used.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
6bf19ad197b0076e48be8720659d38413d438e26 
diff --git a/net/core/dev.c b/net/core/dev.c
index 38b03da..113d216 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4469,4 +4469,3 @@ EXPORT_SYMBOL(br_fdb_put_hook);
 EXPORT_SYMBOL(dev_load);
 #endif
 
-EXPORT_PER_CPU_SYMBOL(softnet_data);

