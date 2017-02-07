From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v3 1/5] bpf: Add missing header to the library
Date: Tue,  7 Feb 2017 21:56:05 +0100
Message-ID: <20170207205609.8035-2-mic@digikod.net>
References: <20170207205609.8035-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org,
        Wang Nan <wangnan0@huawei.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh2.infomaniak.ch ([128.65.195.6]:57439 "EHLO
        smtp-sh2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932357AbdBGU5E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 15:57:04 -0500
In-Reply-To: <20170207205609.8035-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include stddef.h to define size_t.

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
