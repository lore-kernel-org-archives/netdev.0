From: Eric Leblond <eric@regit.org>
Subject: [PATCH 6/8] tools lib bpf: improve warning
Date: Sun, 16 Oct 2016 23:18:32 +0200
Message-ID: <20161016211834.11732-7-eric@regit.org>
References: <20161016211834.11732-1-eric@regit.org>
Cc: linux-kernel@vger.kernel.org, ast@fb.com,
        Eric Leblond <eric@regit.org>
To: netdev@vger.kernel.org, wangnan0@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:45267 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757221AbcJPVVS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 17:21:18 -0400
In-Reply-To: <20161016211834.11732-1-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Leblond <eric@regit.org>
---
 tools/lib/bpf/libbpf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 7cd341e..1fe4532 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -802,7 +802,8 @@ bpf_object__create_maps(struct bpf_object *obj)
 			size_t j;
 			int err = *pfd;
 
-			pr_warning("failed to create map: %s\n",
+			pr_warning("failed to create map (name: '%s'): %s\n",
+				   obj->maps[i].name,
 				   strerror(errno));
 			for (j = 0; j < i; j++)
 				zclose(obj->maps[j].fd);
-- 
2.9.3
