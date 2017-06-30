From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 04/11] sctp: remove the typedef sctp_cid_action_t
Date: Fri, 30 Jun 2017 11:52:15 +0800
Message-ID: <bd4d24bbff8ff402d30c8a148f6ea4332beb5005.1498794482.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
 <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
 <9b26ac600c9c3f9426b370ecd69261c25d220b2b.1498794482.git.lucien.xin@gmail.com>
 <d522a5f819078da037df984f9fa1897b0cf57433.1498794482.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34892 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdF3DxP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:53:15 -0400
In-Reply-To: <d522a5f819078da037df984f9fa1897b0cf57433.1498794482.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove this typedef, there is even no places using it.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 6d7b884..ffdccb4 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -117,12 +117,12 @@ enum sctp_cid {
  *  the action that must be taken if the processing endpoint does not
  *  recognize the Chunk Type.
  */
-typedef enum {
+enum {
 	SCTP_CID_ACTION_DISCARD     = 0x00,
 	SCTP_CID_ACTION_DISCARD_ERR = 0x40,
 	SCTP_CID_ACTION_SKIP        = 0x80,
 	SCTP_CID_ACTION_SKIP_ERR    = 0xc0,
-} sctp_cid_action_t;
+};
 
 enum { SCTP_CID_ACTION_MASK = 0xc0, };
 
-- 
2.1.0
