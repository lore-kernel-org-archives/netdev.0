From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [ethtool PATCH 1/1] bug fix: SFP Tx BIAS uses memory wrong offset
Date: Wed, 15 Oct 2014 06:09:00 -0400
Message-ID: <1413367740-11118-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:56845 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbaJOKJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 06:09:12 -0400
Received: by mail-wi0-f177.google.com with SMTP id fb4so1393333wid.16
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 03:09:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

SFF-8472 rev 12.0 indicates the SFP BIAS is at offset 100 of page A2

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 sfpdiag.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/sfpdiag.c b/sfpdiag.c
index 812a2fa..a3dbc9b 100644
--- a/sfpdiag.c
+++ b/sfpdiag.c
@@ -48,7 +48,7 @@
 #define SFF_A2_VCC_HWARN                  12
 #define SFF_A2_VCC_LWARN                  14
 
-#define SFF_A2_BIAS                       96
+#define SFF_A2_BIAS                       100
 #define SFF_A2_BIAS_HALRM                 16
 #define SFF_A2_BIAS_LALRM                 18
 #define SFF_A2_BIAS_HWARN                 20
-- 
1.7.9.5
