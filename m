From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next 0/2] BPF, kprobes: Add current_in_cgroup helper
Date: Sat, 6 Aug 2016 21:06:53 -0700
Message-ID: <20160807040651.GA9262@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:37906 "EHLO
	mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbcHGEG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2016 00:06:56 -0400
Received: by mail-it0-f46.google.com with SMTP id j124so56948020ith.1
        for <netdev@vger.kernel.org>; Sat, 06 Aug 2016 21:06:56 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset includes a helper and an example to determine whether the kprobe 
is currently executing in the context of a specific cgroup based on a cgroup
bpf map / array. 

Sargun Dhillon (2):
  bpf: Add bpf_current_in_cgroup helper
  samples/bpf: Add example using current_in_cgroup

 include/linux/bpf.h                        | 24 +++++++++++
 include/uapi/linux/bpf.h                   | 11 +++++
 kernel/bpf/arraymap.c                      |  2 +-
 kernel/bpf/verifier.c                      |  4 +-
 kernel/trace/bpf_trace.c                   | 34 +++++++++++++++
 net/core/filter.c                          | 11 ++---
 samples/bpf/Makefile                       |  4 ++
 samples/bpf/bpf_helpers.h                  |  2 +
 samples/bpf/trace_current_in_cgroup_kern.c | 44 ++++++++++++++++++++
 samples/bpf/trace_current_in_cgroup_user.c | 66 ++++++++++++++++++++++++++++++
 10 files changed, 193 insertions(+), 9 deletions(-)
 create mode 100644 samples/bpf/trace_current_in_cgroup_kern.c
 create mode 100644 samples/bpf/trace_current_in_cgroup_user.c

-- 
2.7.4
