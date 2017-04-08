From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH net-next] bpf: fix comment typo
Date: Sat,  8 Apr 2017 22:08:10 +0200
Message-ID: <1491682090-29824-1-git-send-email-alexander@alemayhu.com>
Cc: daniel@iogearbox.net, ast@fb.com,
        Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:35666 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbdDHUIT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 16:08:19 -0400
Received: by mail-wr0-f179.google.com with SMTP id o21so98705956wrb.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 13:08:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o s/bpf_bpf_get_socket_cookie/bpf_get_socket_cookie

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 include/uapi/linux/bpf.h       | 2 +-
 tools/include/uapi/linux/bpf.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index a1d95386f562..1e062bb54eec 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -472,7 +472,7 @@ union bpf_attr {
  *       > 0 length of the string including the trailing NUL on success
  *       < 0 error
  *
- * u64 bpf_bpf_get_socket_cookie(skb)
+ * u64 bpf_get_socket_cookie(skb)
  *     Get the cookie for the socket stored inside sk_buff.
  *     @skb: pointer to skb
  *     Return: 8 Bytes non-decreasing number on success or 0 if the socket
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index a1d95386f562..1e062bb54eec 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -472,7 +472,7 @@ union bpf_attr {
  *       > 0 length of the string including the trailing NUL on success
  *       < 0 error
  *
- * u64 bpf_bpf_get_socket_cookie(skb)
+ * u64 bpf_get_socket_cookie(skb)
  *     Get the cookie for the socket stored inside sk_buff.
  *     @skb: pointer to skb
  *     Return: 8 Bytes non-decreasing number on success or 0 if the socket
-- 
2.7.4
