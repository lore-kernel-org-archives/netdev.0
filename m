From: Eric Leblond <eric@regit.org>
Subject: [PATCH] tools lib bpf: improve warning
Date: Sun, 20 Aug 2017 21:48:14 +0200
Message-ID: <20170820194814.13785-1-eric@regit.org>
Cc: Eric Leblond <eric@regit.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:57216 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753183AbdHTTs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Aug 2017 15:48:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Leblond <eric@regit.org>
---
 tools/lib/bpf/libbpf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 1cc3ea0ffdc3..35f6dfcdc565 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -879,7 +879,8 @@ bpf_object__create_maps(struct bpf_object *obj)
 			size_t j;
 			int err = *pfd;
 
-			pr_warning("failed to create map: %s\n",
+			pr_warning("failed to create map (name: '%s'): %s\n",
+				   obj->maps[i].name,
 				   strerror(errno));
 			for (j = 0; j < i; j++)
 				zclose(obj->maps[j].fd);
-- 
2.14.1
