From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v1 1/7] bpf: Add missing header to the library
Date: Mon,  6 Feb 2017 00:14:22 +0100
Message-ID: <20170205231428.23846-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Including stddef.h is needed to define size_t.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
---
 tools/lib/bpf/bpf.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index a2f9853dd882..df6e186da788 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -22,6 +22,7 @@
 #define __BPF_BPF_H
 
 #include <linux/bpf.h>
+#include <stddef.h>
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 		   int max_entries, __u32 map_flags);
-- 
2.11.0
