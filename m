From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH RFC v3 4/4] samples/bpf: Add documentation on cross compilation
Date: Sun,  3 Sep 2017 11:25:49 -0700
Message-ID: <20170903182549.30866-4-joelaf@google.com>
References: <20170903182549.30866-1-joelaf@google.com>
Cc: kernel-team@android.com, Juri Lelli <juri.lelli@arm.com>,
        Alison Chaiken <alison@she-devel.com>,
        Chenbo Feng <fengc@google.com>,
        Joel Fernandes <joelaf@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170903182549.30866-1-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC: Alexei Starovoitov <ast@kernel.org>
CC: Daniel Borkmann <daniel@iogearbox.net>
CC: David Miller <davem@davemloft.net>
Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 samples/bpf/README.rst | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
index 79f9a58f1872..2b906127ef54 100644
--- a/samples/bpf/README.rst
+++ b/samples/bpf/README.rst
@@ -64,3 +64,13 @@ It is also possible to point make to the newly compiled 'llc' or
 'clang' command via redefining LLC or CLANG on the make command line::
 
  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
+
+Cross compiling samples
+-----------------------
+Inorder to cross-compile, say for arm64 targets, export CROSS_COMPILE and ARCH
+environment variables before calling make. This will direct make to build
+samples for the cross target.
+
+export ARCH=arm64
+export CROSS_COMPILE="aarch64-linux-gnu-"
+make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
-- 
2.14.1.581.gf28d330327-goog
