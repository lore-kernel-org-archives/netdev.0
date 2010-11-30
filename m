From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/11] tipc: Delete unused configuration service structure definition
Date: Tue, 30 Nov 2010 17:00:55 -0500
Message-ID: <1291154463-26346-4-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58701 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab0K3WBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:10 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Removes a structure definition that is no longer used by TIPC's
configuration service.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 5bb3696..2ee5a9a 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -41,13 +41,6 @@
 #include "user_reg.h"
 #include "config.h"
 
-struct subscr_data {
-	char usr_handle[8];
-	u32 domain;
-	u32 port_ref;
-	struct list_head subd_list;
-};
-
 struct manager {
 	u32 user_ref;
 	u32 port_ref;
-- 
1.7.3.2.146.g2d444

