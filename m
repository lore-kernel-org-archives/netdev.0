From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 07/11] sctp: remove the typedef sctp_param_action_t
Date: Fri, 30 Jun 2017 11:52:18 +0800
Message-ID: <81c68360c17817528e46216d9d48168b35e44434.1498794482.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
 <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
 <9b26ac600c9c3f9426b370ecd69261c25d220b2b.1498794482.git.lucien.xin@gmail.com>
 <d522a5f819078da037df984f9fa1897b0cf57433.1498794482.git.lucien.xin@gmail.com>
 <bd4d24bbff8ff402d30c8a148f6ea4332beb5005.1498794482.git.lucien.xin@gmail.com>
 <2ae031641ce87e8fa77af7d3ea31b163f6c25f3d.1498794482.git.lucien.xin@gmail.com>
 <794094c6a1a0fdbf5374c983b2558e1316a51fd4.1498794482.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35036 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752145AbdF3Dxl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:53:41 -0400
In-Reply-To: <794094c6a1a0fdbf5374c983b2558e1316a51fd4.1498794482.git.lucien.xin@gmail.com>
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
index 5eecc0f..d5c0dda 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -216,12 +216,12 @@ enum sctp_param {
  *  not recognize the Parameter Type.
  *
  */
-typedef enum {
+enum {
 	SCTP_PARAM_ACTION_DISCARD     = cpu_to_be16(0x0000),
 	SCTP_PARAM_ACTION_DISCARD_ERR = cpu_to_be16(0x4000),
 	SCTP_PARAM_ACTION_SKIP        = cpu_to_be16(0x8000),
 	SCTP_PARAM_ACTION_SKIP_ERR    = cpu_to_be16(0xc000),
-} sctp_param_action_t;
+};
 
 enum { SCTP_PARAM_ACTION_MASK = cpu_to_be16(0xc000), };
 
-- 
2.1.0
