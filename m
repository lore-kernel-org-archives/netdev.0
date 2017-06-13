From: David Daney <david.daney@cavium.com>
Subject: [PATCH 0/4] bpf: Changes needed (or desired) for MIPS support
Date: Tue, 13 Jun 2017 16:49:34 -0700
Message-ID: <20170613234938.4823-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a grab bag of changes to the bpf testing infrastructure I
developed working on MIPS eBPF JIT support.  The change to
bpf_jit_disasm is probably universally beneficial, the others are more
MIPS specific.

David Daney (4):
  tools: bpf_jit_disasm:  Handle large images.
  test_bpf: Add test to make conditional jump cross a large number of
    insns.
  bpf: Add MIPS support to samples/bpf.
  samples/bpf: Fix tracex5 to work with MIPS syscalls.

 lib/test_bpf.c             | 32 ++++++++++++++++++++++++++++++++
 samples/bpf/Makefile       | 13 +++++++++++++
 samples/bpf/bpf_helpers.h  | 13 +++++++++++++
 samples/bpf/syscall_nrs.c  | 12 ++++++++++++
 samples/bpf/tracex5_kern.c | 11 ++++++++---
 tools/net/bpf_jit_disasm.c | 37 ++++++++++++++++++++++++++-----------
 6 files changed, 104 insertions(+), 14 deletions(-)
 create mode 100644 samples/bpf/syscall_nrs.c

-- 
2.9.4
