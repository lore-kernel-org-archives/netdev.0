From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 01/14] sctp: remove the unused typedef sctp_packet_phandler_t
Date: Fri, 11 Aug 2017 10:23:45 +0800
Message-ID: <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34714 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752096AbdHKCYN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:24:13 -0400
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove this function typedef, there is even no places
using it.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index fbe6e81..73e9509 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -657,8 +657,6 @@ struct sctp_sockaddr_entry {
 
 #define SCTP_ADDRESS_TICK_DELAY	500
 
-typedef struct sctp_chunk *(sctp_packet_phandler_t)(struct sctp_association *);
-
 /* This structure holds lists of chunks as we are assembling for
  * transmission.
  */
-- 
2.1.0
