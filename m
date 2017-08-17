From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH v2] bpf: Update sysctl documentation to list all supported architectures
Date: Thu, 17 Aug 2017 20:30:39 +1000
Message-ID: <1502965839-23115-1-git-send-email-mpe@ellerman.id.au>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ast@kernel.org, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:33513 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750988AbdHQKap (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 06:30:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sysctl documentation states that the JIT is only available on
x86_64, which is no longer correct.

Update the list, and break it out to indicate which architectures
support the cBPF JIT (via HAVE_CBPF_JIT) or the eBPF JIT
(HAVE_EBPF_JIT).

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 Documentation/sysctl/net.txt | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

v2: Split the list based on cBPF vs eBPF.

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 14db18c970b1..b9c3c6078010 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -36,8 +36,23 @@ bpf_jit_enable
 --------------
 
 This enables Berkeley Packet Filter Just in Time compiler.
-Currently supported on x86_64 architecture, bpf_jit provides a framework
-to speed packet filtering, the one used by tcpdump/libpcap for example.
+
+There are two flavors of JIT, the new eBPF JIT supported on:
+  - x86_64
+  - arm64
+  - ppc64
+  - sparc64
+  - mips64
+
+And the older cBPF JIT supported on:
+  - arm
+  - mips
+  - ppc
+  - sparc
+
+The BPF JIT provides a framework to speed packet filtering, the one used by
+tcpdump/libpcap for example.
+
 Values :
 	0 - disable the JIT (default value)
 	1 - enable the JIT
-- 
2.7.4
