From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 4/9 net-next-2.6] [TIPC]: Fix null pointer dereference in debug code
Date: Mon, 28 Apr 2008 15:48:41 -0400
Message-ID: <1209412126-2109-5-git-send-email-allan.stephens@windriver.com>
References: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33667 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933837AbYD1TwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 15:52:04 -0400
In-Reply-To: <1209412126-2109-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates an obsolete use of the DBG_OUTPUT print
buffer which could lead to a null pointer crash in tipc_printf()
if TIPC's debugging capabilities are configured.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/name_distr.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 39fd161..aecba5c 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -41,9 +41,6 @@
 #include "msg.h"
 #include "name_distr.h"
 
-#undef  DBG_OUTPUT
-#define DBG_OUTPUT NULL
-
 #define ITEM_SIZE sizeof(struct distr_item)
 
 /**
-- 
1.5.3.2

