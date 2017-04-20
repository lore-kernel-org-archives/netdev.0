From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, doc: update bpf maintainers entry
Date: Thu, 20 Apr 2017 17:27:58 +0200
Message-ID: <509f15e49a4546260785ab72cab8dcc153251e66.1492701796.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45996 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970561AbdDTP23 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:28:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add various related files that have been missing under
BPF entry covering essential parts of its infrastructure
and also add myself as co-maintainer.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 MAINTAINERS | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 676c139..c2b1223 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2585,12 +2585,26 @@ F:	include/uapi/linux/if_bonding.h
 
 BPF (Safe dynamic programs and tools)
 M:	Alexei Starovoitov <ast@kernel.org>
+M:	Daniel Borkmann <daniel@iogearbox.net>
 L:	netdev@vger.kernel.org
 L:	linux-kernel@vger.kernel.org
 S:	Supported
+F:	arch/x86/net/bpf_jit*
+F:	Documentation/networking/filter.txt
+F:	include/linux/bpf*
+F:	include/linux/filter.h
+F:	include/uapi/linux/bpf*
+F:	include/uapi/linux/filter.h
 F:	kernel/bpf/
-F:	tools/testing/selftests/bpf/
+F:	kernel/trace/bpf_trace.c
 F:	lib/test_bpf.c
+F:	net/bpf/
+F:	net/core/filter.c
+F:	net/sched/act_bpf.c
+F:	net/sched/cls_bpf.c
+F:	samples/bpf/
+F:	tools/net/bpf*
+F:	tools/testing/selftests/bpf/
 
 BROADCOM B44 10/100 ETHERNET DRIVER
 M:	Michael Chan <michael.chan@broadcom.com>
-- 
1.9.3
