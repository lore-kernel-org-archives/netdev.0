From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 04/11] sctp: remove the typedef sctp_gap_ack_block_t
Date: Sun, 23 Jul 2017 09:34:29 +0800
Message-ID: <303fa591073b161b9434fa7f81a8d9d119954359.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
 <daa1cc9a380f5a1eb37b3d30fd64942d310fe81d.1500773578.git.lucien.xin@gmail.com>
 <78a33af4a9d7ef7116637943dbd0ae1403d20114.1500773578.git.lucien.xin@gmail.com>
 <54eca4d5d79aae83b386754b4613edc388521d54.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36087 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755172AbdGWBfR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:35:17 -0400
In-Reply-To: <54eca4d5d79aae83b386754b4613edc388521d54.1500773578.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_gap_ack_block_t, and
replace with struct sctp_gap_ack_block in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index c323b3e..b84b8e8 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -363,16 +363,16 @@ struct sctp_unrecognized_param {
  *  subsequences of DATA chunks as represented by their TSNs.
  */
 
-typedef struct sctp_gap_ack_block {
+struct sctp_gap_ack_block {
 	__be16 start;
 	__be16 end;
-} sctp_gap_ack_block_t;
+};
 
 typedef __be32 sctp_dup_tsn_t;
 
 typedef union {
-	sctp_gap_ack_block_t	gab;
-        sctp_dup_tsn_t		dup;
+	struct sctp_gap_ack_block gab;
+	sctp_dup_tsn_t dup;
 } sctp_sack_variable_t;
 
 typedef struct sctp_sackhdr {
-- 
2.1.0
