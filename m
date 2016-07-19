From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v3 0/2] bpf: add copy_to_user helper & example
Date: Tue, 19 Jul 2016 02:32:16 -0700
Message-ID: <20160719093214.GA23733@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series contains two patches that add support for a copy_to_user
helper to BPF programs. This allows them to manipulate user memory during
the course of tracing. The second patch in the series has an example that
uses it, in one the intended ways to divert execution.

Thanks to Alexei Starovoitov for review, I've made changes based on his
recommendations.
---
v1->v2: restrict writing to user space, as opposed to globally
v2->v3: Fixed formatting issues

Sargun Dhillon (2):
  bpf: Add bpf_copy_to_user BPF helper to be called in tracers (kprobes)
  samples/bpf: Add example of using bpf_copy_to_user in bpf kprobes

 include/uapi/linux/bpf.h   | 11 +++++++
 kernel/trace/bpf_trace.c   | 31 +++++++++++++++++++
 samples/bpf/Makefile       |  4 +++
 samples/bpf/bpf_helpers.h  |  2 ++
 samples/bpf/tracex7_kern.c | 51 +++++++++++++++++++++++++++++++
 samples/bpf/tracex7_user.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 174 insertions(+)
 create mode 100644 samples/bpf/tracex7_kern.c
 create mode 100644 samples/bpf/tracex7_user.c

-- 
2.7.4
