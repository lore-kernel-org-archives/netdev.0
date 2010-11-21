From: Joe Perches <joe@perches.com>
Subject: [PATCH 14/62] cxgb4vf: Use static const
Date: Sat, 20 Nov 2010 18:38:15 -0800
Message-ID: <d0a433aa6bbe20dfe4fd4f3ca9aec50f97601403.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1650 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756178Ab0KUCjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:39:54 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  10179	     56	   2216	  12451	   30a3	drivers/net/cxgb4vf/t4vf_hw.o.new
  10179	     56	   2216	  12451	   30a3	drivers/net/cxgb4vf/t4vf_hw.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/cxgb4vf/t4vf_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
index f7d7f97..daedf6e 100644
--- a/drivers/net/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/cxgb4vf/t4vf_hw.c
@@ -116,7 +116,7 @@ static void dump_mbox(struct adapter *adapter, const char *tag, u32 mbox_data)
 int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 		      void *rpl, bool sleep_ok)
 {
-	static int delay[] = {
+	static const int delay[] = {
 		1, 1, 3, 5, 10, 10, 20, 50, 100
 	};
 
-- 
1.7.3.2.245.g03276.dirty

