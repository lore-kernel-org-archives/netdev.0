From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/3] BPF event output helper improvements
Date: Wed, 13 Jul 2016 00:36:16 +0200
Message-ID: <cover.1468362046.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44872 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbcGLWgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 18:36:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds improvements to the BPF event output helper to
support non-linear data sampling, here specifically, for skb
context. For details please see individual patches. The set
is based against net-next tree.

Thanks a lot!

Daniel Borkmann (3):
  perf, events: add non-linear data support for raw records
  bpf, perf: split bpf_perf_event_output
  bpf: avoid stack copy and use skb ctx for event output

 arch/s390/kernel/perf_cpum_sf.c |  2 ++
 arch/x86/events/amd/ibs.c       |  2 ++
 include/linux/bpf.h             |  5 +++-
 include/linux/perf_event.h      |  8 ++++++
 include/uapi/linux/bpf.h        |  2 ++
 kernel/bpf/core.c               |  8 ++++--
 kernel/events/core.c            | 13 +++++++--
 kernel/events/internal.h        | 18 +++++++++---
 kernel/trace/bpf_trace.c        | 64 ++++++++++++++++++++++-------------------
 net/core/filter.c               | 43 ++++++++++++++++++++++++++-
 10 files changed, 125 insertions(+), 40 deletions(-)

-- 
1.9.3
