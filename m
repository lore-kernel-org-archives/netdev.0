From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH v4 0/4] Add cross-compilation support to eBPF samples
Date: Wed, 20 Sep 2017 09:04:32 -0700
Message-ID: <20170920160436.24689-1-joelaf@google.com>
Cc: alison@she-devel.com, juri.lelli@arm.com, fengc@google.com,
        daniel@iogearbox.net, davem@davemloft.net, ast@kernel.org,
        kernel-team@android.com, Joel Fernandes <joelaf@google.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches fix issues seen when cross-compiling eBPF samples on arm64.
Compared to [1], I dropped the controversial inline-asm patch and exploring
other options to fix it. However these patches are a step in the right
direction and I look forward to getting them into -next and the merge window.

Changes since v3:
- just a repost with acks

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

-- 
2.14.1.821.g8fa685d3b7-goog
