From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v4 3/3] samples/bpf: Add missing header
Date: Wed,  8 Feb 2017 21:27:44 +0100
Message-ID: <20170208202744.16274-4-mic@digikod.net>
References: <20170208202744.16274-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, Wang Nan <wangnan0@huawei.com>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh2.infomaniak.ch ([128.65.195.6]:38334 "EHLO
        smtp-sh2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdBHUa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:30:27 -0500
In-Reply-To: <20170208202744.16274-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include unistd.h to define __NR_getuid and __NR_getsid.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
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
2.11.0
