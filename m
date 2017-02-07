From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 4/4] doc/bpf: describe BCC the BPF Compiler
 Collection
Date: Tue, 07 Feb 2017 15:30:32 +0100
Message-ID: <148647783224.10567.17783943294570297203.stgit@localhost>
References: <148647756092.10567.10947541548678801938.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, alexander@alemayhu.com,
        linux-kernel@vger.kernel.org, quentin.monnet@6wind.com,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>
To: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <148647756092.10567.10947541548678801938.stgit@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is worth mentioning BCC (BPF Compiler Collection) in-order
to direct developers into that community.

Reviewed-by: Alexander Alemayhu <alexander@alemayhu.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 Documentation/bpf/bcc_tool_chain.rst |   37 ++++++++++++++++++++++++++++++++++
 Documentation/bpf/index.rst          |    5 ++---
 2 files changed, 39 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/bpf/bcc_tool_chain.rst

diff --git a/Documentation/bpf/bcc_tool_chain.rst b/Documentation/bpf/bcc_tool_chain.rst
new file mode 100644
index 000000000000..b721875065bc
--- /dev/null
+++ b/Documentation/bpf/bcc_tool_chain.rst
@@ -0,0 +1,37 @@
+=============================
+BCC (BPF Compiler Collection)
+=============================
+
+BCC is a toolkit to make eBPF programs easier to write, with
+front-ends in Python and Lua.  BCC requires LLVM and clang (in version
+3.7.1 or newer) to be available on target, because BCC programs do
+runtime compilation of the restricted-C code into eBPF instructions.
+
+BCC includes several useful tools_ and examples_, developed by
+recognized performance analyst `Brendan Gregg`_ and covered with a
+tutorial_ and slides_.
+
+.. _tools:
+   https://github.com/iovisor/bcc/tree/master/tools
+
+.. _examples:
+   https://github.com/iovisor/bcc/tree/master/examples
+
+.. _`Brendan Gregg`: http://www.brendangregg.com/
+
+.. _tutorial:
+   https://github.com/iovisor/bcc/blob/master/docs/tutorial.md
+
+.. _slides:
+   http://www.slideshare.net/brendangregg/linux-bpf-superpowers/43/
+
+The project maintains an overview of `eBPF supported kernels`_ and
+what versions got which specific features.  There is also a `BCC
+Reference Guide`_.
+
+.. _eBPF supported kernels:
+   https://github.com/iovisor/bcc/blob/master/docs/kernel-versions.md
+
+.. _BCC Reference Guide:
+   https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md
+
diff --git a/Documentation/bpf/index.rst b/Documentation/bpf/index.rst
index 618a28f7e959..686cc33fffab 100644
--- a/Documentation/bpf/index.rst
+++ b/Documentation/bpf/index.rst
@@ -35,7 +35,7 @@ the `bpf(2)`_ syscall.
 
 This documentation is focused on the kernel tree's `samples/bpf/`_ and
 `tools/lib/bpf/`_.  It is worth mentioning that other projects exist,
-like BCC_, that has a slightly different user-facing
+like :doc:`bcc_tool_chain`, that has a slightly different user-facing
 syntax, but is interfacing with the same kernel facilities as those
 covered by this documentation.
 
@@ -44,6 +44,7 @@ covered by this documentation.
 
    ebpf_maps
    ebpf_maps_types
+   bcc_tool_chain
 
 .. links:
 
@@ -65,5 +66,3 @@ covered by this documentation.
 
 .. _Traffic control: http://man7.org/linux/man-pages/man8/tc-bpf.8.html
 
-.. _BCC: https://github.com/iovisor/bcc
-
