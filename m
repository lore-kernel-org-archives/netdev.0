From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next] Fix inaccurate helper function description
Date: Wed, 26 Apr 2017 16:41:23 -0700
Message-ID: <1493250083-1954-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, mic@digikod.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36363 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032961AbdDZXlg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:41:36 -0400
Received: by mail-pf0-f195.google.com with SMTP id v14so3657638pfd.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 16:41:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

The description inside uapi/linux/bpf.h about bpf_get_socket_uid
helper function is no longer valid. It returns overflowuid rather
than 0 when failed.

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 include/uapi/linux/bpf.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index e553529..945a1f5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -481,8 +481,7 @@ union bpf_attr {
  * u32 bpf_get_socket_uid(skb)
  *     Get the owner uid of the socket stored inside sk_buff.
  *     @skb: pointer to skb
- *     Return: uid of the socket owner on success or 0 if the socket pointer
- *     inside sk_buff is NULL
+ *     Return: uid of the socket owner on success or overflowuid if failed.
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
-- 
2.7.4
