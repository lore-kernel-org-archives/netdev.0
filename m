From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH] bpf: Update sysctl documentation to list all supported architectures
Date: Wed, 16 Aug 2017 15:15:57 +1000
Message-ID: <1502860557-20247-1-git-send-email-mpe@ellerman.id.au>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ast@kernel.org, daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sysctl documentation states that the JIT is only available on
x86_64, which is no longer correct.

Update the list to include all architectures that enable HAVE_CBPF_JIT
or HAVE_EBPF_JIT under some configuration.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 Documentation/sysctl/net.txt | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 14db18c970b1..f68356024d09 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -36,8 +36,9 @@ bpf_jit_enable
 --------------
 
 This enables Berkeley Packet Filter Just in Time compiler.
-Currently supported on x86_64 architecture, bpf_jit provides a framework
-to speed packet filtering, the one used by tcpdump/libpcap for example.
+Currently supported on arm, arm64, mips, powerpc, s390, sparc and x86_64
+architectures, bpf_jit provides a framework to speed packet filtering, the one
+used by tcpdump/libpcap for example.
 Values :
 	0 - disable the JIT (default value)
 	1 - enable the JIT
-- 
2.7.4
