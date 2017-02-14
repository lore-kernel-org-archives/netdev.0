From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 13/15] samples/bpf: Add missing header
Date: Mon, 13 Feb 2017 22:13:58 -0300
Message-ID: <20170214011400.13352-14-acme@kernel.org>
References: <20170214011400.13352-1-acme@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214011400.13352-1-acme@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mickaël Salaün <mic@digikod.net>

Include unistd.h to define __NR_getuid and __NR_getsid.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Acked-by: Joe Stringer <joe@ovn.org>
Acked-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20170208202744.16274-4-mic@digikod.net
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 samples/bpf/tracex5_kern.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/samples/bpf/tracex5_kern.c b/samples/bpf/tracex5_kern.c
index fd12d7154d42..7e4cf74553ff 100644
--- a/samples/bpf/tracex5_kern.c
+++ b/samples/bpf/tracex5_kern.c
@@ -8,6 +8,7 @@
 #include <linux/version.h>
 #include <uapi/linux/bpf.h>
 #include <uapi/linux/seccomp.h>
+#include <uapi/linux/unistd.h>
 #include "bpf_helpers.h"
 
 #define PROG(F) SEC("kprobe/"__stringify(F)) int bpf_func_##F
-- 
2.9.3
