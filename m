From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] BPF updates
Date: Mon, 18 Apr 2016 00:29:06 +0200
Message-ID: <cover.1460931309.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This minor set adds a new helper bpf_skb_event_output() for eBPF cls/act
program types which allows to pass events to user space applications. For
details, please see individual patches.

Thanks!

Daniel Borkmann (2):
  bpf, trace: add BPF_F_CURRENT_CPU flag for bpf_perf_event_output
  bpf: add event output helper for notifications/sampling/logging

 include/linux/bpf.h      |  2 ++
 include/uapi/linux/bpf.h |  4 ++++
 kernel/trace/bpf_trace.c |  7 ++++++-
 net/core/filter.c        | 30 ++++++++++++++++++++++++++++++
 4 files changed, 42 insertions(+), 1 deletion(-)

-- 
1.9.3
