From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/5] net: filter: doc: add section for BPF test suite
Date: Fri, 23 May 2014 18:43:59 +0200
Message-ID: <1400863441-3711-4-git-send-email-dborkman@redhat.com>
References: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752792AbaEWQoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 12:44:11 -0400
In-Reply-To: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mention the recently added test suite in the documentation file.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 Documentation/networking/filter.txt | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 748fd38..dc7dcc8 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -833,6 +833,20 @@ loops and other CFG validation; second step starts from the first insn and
 descends all possible paths. It simulates execution of every insn and observes
 the state change of registers and stack.
 
+Testing
+-------
+
+Next to the BPF toolchain, the kernel also ships a test module that contains
+various test cases for classic and internal BPF that can be executed against
+the BPF interpreter and JIT compiler. It can be found in lib/test_bpf.c and
+enabled via Kconfig:
+
+  CONFIG_TEST_BPF=m
+
+After the module has been built and installed, the test suite can be executed
+via insmod or modprobe against 'test_bpf' module. Results of the test cases
+including timings in nsec can be found in the kernel log (dmesg).
+
 Misc
 ----
 
-- 
1.7.11.7
