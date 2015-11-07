From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] bpf: doc: correct arch list for supported eBPF JIT
Date: Fri,  6 Nov 2015 21:38:58 -0800
Message-ID: <1446874738-14589-1-git-send-email-yang.shi@linaro.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, yang.shi@linaro.org
To: ast@kernel.org, daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

aarch64 and s390x support eBPF JIT too, correct document to reflect this and
avoid any confusion.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 Documentation/networking/filter.txt | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 135581f..96da119 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -596,9 +596,9 @@ skb pointer). All constraints and restrictions from bpf_check_classic() apply
 before a conversion to the new layout is being done behind the scenes!
 
 Currently, the classic BPF format is being used for JITing on most of the
-architectures. Only x86-64 performs JIT compilation from eBPF instruction set,
-however, future work will migrate other JIT compilers as well, so that they
-will profit from the very same benefits.
+architectures. x86-64, aarch64 and s390x perform JIT compilation from eBPF
+instruction set, however, future work will migrate other JIT compilers as well,
+so that they will profit from the very same benefits.
 
 Some core changes of the new internal format:
 
-- 
2.0.2
