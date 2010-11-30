From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/11] tipc: Eliminate an unused symbolic constant in link code
Date: Tue, 30 Nov 2010 17:01:01 -0500
Message-ID: <1291154463-26346-10-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58731 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab0K3WBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:15 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Removes a symbol that is not referenced anywhere by TIPC's link code.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index aee6579..cf414cf 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -49,12 +49,6 @@
 #define INVALID_SESSION 0x10000
 
 /*
- * Limit for deferred reception queue:
- */
-
-#define DEF_QUEUE_LIMIT 256u
-
-/*
  * Link state events:
  */
 
-- 
1.7.3.2.146.g2d444

