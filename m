From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: [PATCH net-next] bpf, doc: Add arm32 as arch supporting eBPF JIT
Date: Wed, 23 Aug 2017 21:29:10 +0530
Message-ID: <1503503950-5146-1-git-send-email-illusionist.neo@gmail.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@fb.com,
        Shubham Bansal <illusionist.neo@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:38189 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932118AbdHWP73 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 11:59:29 -0400
Received: by mail-pg0-f67.google.com with SMTP id t3so386766pgt.5
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 08:59:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As eBPF JIT support for arm32 was added recently with
commit 39c13c204bb1150d401e27d41a9d8b332be47c49, it seems appropriate to
add arm32 as arch with support for eBPF JIT in bpf and sysctl docs as well.

Signed-off-by: Shubham Bansal <illusionist.neo@gmail.com>
---
 Documentation/networking/filter.txt | 4 ++--
 Documentation/sysctl/net.txt        | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 6a0df8d..e5e33ba 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -596,8 +596,8 @@ skb pointer). All constraints and restrictions from bpf_check_classic() apply
 before a conversion to the new layout is being done behind the scenes!
 
 Currently, the classic BPF format is being used for JITing on most 32-bit
-architectures, whereas x86-64, aarch64, s390x, powerpc64, sparc64 perform JIT
-compilation from eBPF instruction set.
+architectures, whereas x86-64, aarch64, s390x, powerpc64, sparc64, arm32 perform
+JIT compilation from eBPF instruction set.
 
 Some core changes of the new internal format:
 
diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 28596e0..b67044a 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -46,13 +46,13 @@ translate these BPF proglets into native CPU instructions. There are
 two flavors of JITs, the newer eBPF JIT currently supported on:
   - x86_64
   - arm64
+  - arm32
   - ppc64
   - sparc64
   - mips64
   - s390x
 
 And the older cBPF JIT supported on the following archs:
-  - arm
   - mips
   - ppc
   - sparc
-- 
2.7.4
