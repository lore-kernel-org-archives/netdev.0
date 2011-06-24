From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/20] tipc: Remove unnecessary includes in socket code
Date: Fri, 24 Jun 2011 18:07:21 -0400
Message-ID: <1308953247-25266-15-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34402 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757304Ab1FXWHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:51 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates a pair of #include statements for files that are brought in
automatically by including core.h.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3388373..adb2eff 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -36,9 +36,6 @@
 
 #include <net/sock.h>
 
-#include <linux/tipc.h>
-#include <linux/tipc_config.h>
-
 #include "core.h"
 #include "port.h"
 
-- 
1.7.4.4

