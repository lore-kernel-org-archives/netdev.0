From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH RFC v3 0/4] Add cross-compilation support to eBPF samples
Date: Sun,  3 Sep 2017 11:23:21 -0700
Message-ID: <20170903182326.30547-1-joelaf@google.com>
Cc: kernel-team@android.com, Juri Lelli <juri.lelli@arm.com>,
        Alison Chaiken <alison@she-devel.com>,
        Chenbo Feng <fengc@google.com>,
        Joel Fernandes <joelaf@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches fix issues seen when cross-compiling eBPF samples on arm64.
Compared to [1], I dropped the controversial inline-asm patch pending further
discussion on the right way to do it. However these patches are still a step in
the right direction and I wanted them to get in before the more controversial
bit.

[1] https://lkml.org/lkml/2017/8/7/417

Joel Fernandes (4):
  samples/bpf: Use getppid instead of getpgrp for array map stress
  samples/bpf: Enable cross compiler support
  samples/bpf: Fix pt_regs issues when cross-compiling
  samples/bpf: Add documentation on cross compilation

 samples/bpf/Makefile                      |  7 +++-
 samples/bpf/README.rst                    | 10 ++++++
 samples/bpf/map_perf_test_kern.c          |  2 +-
 samples/bpf/map_perf_test_user.c          |  2 +-
 tools/testing/selftests/bpf/bpf_helpers.h | 56 +++++++++++++++++++++++++++----
 5 files changed, 67 insertions(+), 10 deletions(-)

CC: Alexei Starovoitov <ast@kernel.org>
CC: Daniel Borkmann <daniel@iogearbox.net>
Cc: David Miller <davem@davemloft.net>
-- 
2.14.1.581.gf28d330327-goog
