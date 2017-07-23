From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 05/11] sctp: remove the typedef sctp_dup_tsn_t
Date: Sun, 23 Jul 2017 09:34:30 +0800
Message-ID: <42fb936def0c9ef0522d2e3809c9c07dccb6974f.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
 <daa1cc9a380f5a1eb37b3d30fd64942d310fe81d.1500773578.git.lucien.xin@gmail.com>
 <78a33af4a9d7ef7116637943dbd0ae1403d20114.1500773578.git.lucien.xin@gmail.com>
 <54eca4d5d79aae83b386754b4613edc388521d54.1500773578.git.lucien.xin@gmail.com>
 <303fa591073b161b9434fa7f81a8d9d119954359.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36405 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755172AbdGWBfZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:35:25 -0400
In-Reply-To: <303fa591073b161b9434fa7f81a8d9d119954359.1500773578.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_dup_tsn_t, and replace
with __be32 in the places where it's using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index b84b8e8..8faf74e 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -368,11 +368,9 @@ struct sctp_gap_ack_block {
 	__be16 end;
 };
 
-typedef __be32 sctp_dup_tsn_t;
-
 typedef union {
 	struct sctp_gap_ack_block gab;
-	sctp_dup_tsn_t dup;
+	__be32 dup;
 } sctp_sack_variable_t;
 
 typedef struct sctp_sackhdr {
-- 
2.1.0
