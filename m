From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH iproute2] tc: bpf: add ppc64 and sparc64 to list of archs with eBPF support
Date: Sat,  6 May 2017 22:30:10 +0200
Message-ID: <1494102610-19853-1-git-send-email-alexander@alemayhu.com>
Cc: daniel@iogearbox.net, stephen@networkplumber.org,
        Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37310 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbdEFUaP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 16:30:15 -0400
Received: by mail-wm0-f43.google.com with SMTP id m123so30685865wma.0
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 13:30:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sparc64 support was added in 7a12b5031c6b (sparc64: Add eBPF JIT., 2017-04-17)[0]
and ppc64 in 156d0e290e96 (powerpc/ebpf/jit: Implement JIT compiler for extended BPF, 2016-06-22)[1].

[0]: https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=7a12b5031c6b
[1]: https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=156d0e290e96
Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 man/man8/tc-bpf.8 | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/man8/tc-bpf.8 b/man/man8/tc-bpf.8
index e371964d06ab..2e9812ede028 100644
--- a/man/man8/tc-bpf.8
+++ b/man/man8/tc-bpf.8
@@ -75,9 +75,9 @@ In Linux, it's generally considered that eBPF is the successor of cBPF.
 The kernel internally transforms cBPF expressions into eBPF expressions and
 executes the latter. Execution of them can be performed in an interpreter
 or at setup time, they can be just-in-time compiled (JIT'ed) to run as
-native machine code. Currently, x86_64, ARM64 and s390 architectures have
-eBPF JIT support, whereas PPC, SPARC, ARM and MIPS have cBPF, but did not
-(yet) switch to eBPF JIT support.
+native machine code. Currently, x86_64, ARM64, s390, ppc64 and sparc64
+architectures have eBPF JIT support, whereas PPC, SPARC, ARM and MIPS have
+cBPF, but did not (yet) switch to eBPF JIT support.
 
 eBPF's instruction set has similar underlying principles as the cBPF
 instruction set, it however is modelled closer to the underlying
-- 
2.7.4
