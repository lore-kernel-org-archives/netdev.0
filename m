From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 11/14] sctp: remove the unused typedef sctp_sm_command_t
Date: Fri, 11 Aug 2017 10:23:55 +0800
Message-ID: <6ff85867e2eb2776e2dbec9a0140911dcaec3e18.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
 <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
 <67dec3f4936413e5bf596dc0ce9be0b9aa15a444.1502417340.git.lucien.xin@gmail.com>
 <5031dc5f40135c4ede57452bc61a1b29dfc76d89.1502417340.git.lucien.xin@gmail.com>
 <58f1f86286c91cf55e9d6eb9395e59e9f1fd4519.1502417340.git.lucien.xin@gmail.com>
 <77692e0783b8134d97fd4c15e37cf0b6e4fa643e.1502417340.git.lucien.xin@gmail.com>
 <bec27150caf5435011467a5488247f853f782409.1502417340.git.lucien.xin@gmail.com>
 <d9ac131331781f85d2662c4c15692344260bb1b6.1502417340.git.lucien.xin@gmail.com>
 <d69e6a88f9cbdc68f0f3ef9c2afd89ccc64f955b.1502417340.git.lucien.xin@gmail.com>
 <8a912c943fa40c635ac0dba8726c7e744031a446.1502417340.git.lucien.xin@gmail.com>
 <712be5d964dee4d7918781d7399ad564f2309259.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37216 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752430AbdHKCZd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:25:33 -0400
In-Reply-To: <712be5d964dee4d7918781d7399ad564f2309259.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove this typedef including the struct, there is even no places
using it.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 9af64b9..3ca75a6 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -65,11 +65,6 @@ typedef enum {
 	SCTP_DISPOSITION_BUG,		 /* This is a bug.  */
 } sctp_disposition_t;
 
-typedef struct {
-	int name;
-	int action;
-} sctp_sm_command_t;
-
 typedef sctp_disposition_t (sctp_state_fn_t) (struct net *,
 					      const struct sctp_endpoint *,
 					      const struct sctp_association *,
-- 
2.1.0
