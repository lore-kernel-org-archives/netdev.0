From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/4] doc/bpf: start eBPF documentation tree bpf/
Date: Tue, 07 Feb 2017 15:30:17 +0100
Message-ID: <148647781693.10567.1655837312500141821.stgit@localhost>
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

The learning curve for eBPF programs is hard.  The purpose of this
documentation (subtree) is to make it easier for developers to get
started using and writing eBPF programs.

Including bpf/index under section User-oriented documentation.

Thanks to Quentin Monnet <quentin.monnet@6wind.com> for improving
this document with areas eBFP is used in and early review.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 Documentation/bpf/index.rst |   66 +++++++++++++++++++++++++++++++++++++++++++
 Documentation/index.rst     |    1 +
 2 files changed, 67 insertions(+)
 create mode 100644 Documentation/bpf/index.rst

diff --git a/Documentation/bpf/index.rst b/Documentation/bpf/index.rst
new file mode 100644
index 000000000000..f262fe8f9f95
--- /dev/null
+++ b/Documentation/bpf/index.rst
@@ -0,0 +1,66 @@
+======================================
+eBPF - extended Berkeley Packet Filter
+======================================
+
+Introduction
+============
+
+The Berkeley Packet Filter (BPF) started (`article 1992`_) as a
+special-purpose virtual machine (register based filter evaluator) for
+filtering network packets, best known for its use in tcpdump. It is
+documented in the kernel tree, in the first part of:
+`Documentation/networking/filter.txt`_
+
+The extended BPF (eBPF) variant has become a universal in-kernel
+virtual machine, that has hooks all over the kernel.  The eBPF
+instruction set is quite different, see description in section "BPF
+kernel internals" of `Documentation/networking/filter.txt`_ or look at
+this `presentation by Alexei`_.
+
+Areas using eBPF:
+ * XDP - eXpress Data Path
+ * `Traffic control`_
+ * Sockets
+ * Firewalling (``xt_bpf`` module)
+ * Tracing
+ * Tracepoints
+ * kprobe (dynamic tracing of a kernel function call)
+ * cgroups
+
+Documentation
+=============
+
+The primary user documentation for extended BPF is in the man-page for
+the `bpf(2)`_ syscall.
+
+This documentation is focused on the kernel tree's `samples/bpf/`_ and
+`tools/lib/bpf/`_.  It is worth mentioning that other projects exist,
+like BCC_, that has a slightly different user-facing
+syntax, but is interfacing with the same kernel facilities as those
+covered by this documentation.
+
+.. toctree::
+   :maxdepth: 1
+
+.. links:
+
+.. _article 1992: http://www.tcpdump.org/papers/bpf-usenix93.pdf
+
+.. _bpf(2): http://man7.org/linux/man-pages/man2/bpf.2.html
+
+.. _Documentation/networking/filter.txt:
+   https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/filter.txt
+
+.. _presentation by Alexei:
+   http://www.slideshare.net/AlexeiStarovoitov/bpf-inkernel-virtual-machine
+
+.. _samples/bpf/:
+   https://github.com/torvalds/linux/blob/master/samples/bpf/
+
+.. _tools/lib/bpf/:
+   https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/tools/lib/bpf/
+
+.. _Traffic control: http://man7.org/linux/man-pages/man8/tc-bpf.8.html
+
+.. _BCC: https://github.com/iovisor/bcc
+
diff --git a/Documentation/index.rst b/Documentation/index.rst
index cb5d77699c60..dacf202febb8 100644
--- a/Documentation/index.rst
+++ b/Documentation/index.rst
@@ -23,6 +23,7 @@ trying to get it to work optimally on a given system.
    :maxdepth: 2
 
    admin-guide/index
+   bpf/index
 
 Introduction to kernel development
 ----------------------------------
