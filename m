From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH] Documentation: filter: Add MIPS to architectures with BPF JIT
Date: Wed, 10 Sep 2014 14:51:44 +0100
Message-ID: <1410357104-30490-1-git-send-email-markos.chandras@imgtec.com>
References: <1409322218-3689-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Daniel Borkmann" <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409322218-3689-1-git-send-email-markos.chandras@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MIPS supports BPF JIT since v3.16-rc1

Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Acked-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 Documentation/networking/filter.txt | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index c48a9704bda8..d16f424c5e8d 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -462,9 +462,9 @@ JIT compiler
 ------------
 
 The Linux kernel has a built-in BPF JIT compiler for x86_64, SPARC, PowerPC,
-ARM and s390 and can be enabled through CONFIG_BPF_JIT. The JIT compiler is
-transparently invoked for each attached filter from user space or for internal
-kernel users if it has been previously enabled by root:
+ARM, MIPS and s390 and can be enabled through CONFIG_BPF_JIT. The JIT compiler
+is transparently invoked for each attached filter from user space or for
+internal kernel users if it has been previously enabled by root:
 
   echo 1 > /proc/sys/net/core/bpf_jit_enable
 
-- 
2.1.0
