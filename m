From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next 0/5] BPF updates
Date: Thu, 26 Nov 2015 13:58:28 +0100
Message-ID: <cover.1448541097.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37236 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbbKZM6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 07:58:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some more updates on the BPF front-end to get further eBPF
functionality working with tc. See individual patches for
details. Targeted at iproute2's -next branch.

Thanks!

Daniel Borkmann (5):
  {f,m}_bpf: make tail calls working
  {f,m}_bpf: check map attributes when fetching as pinned
  {f,m}_bpf: allow for user-defined object pinnings
  {f,m}_bpf: allow updates on program arrays
  {f,m}_bpf: add more example code

 etc/iproute2/bpf_pinning    |   6 +
 examples/bpf/README         |  13 +
 examples/bpf/bpf_cyclic.c   |  32 ++
 examples/bpf/bpf_funcs.h    |  11 +
 examples/bpf/bpf_graft.c    |  70 +++++
 examples/bpf/bpf_tailcall.c | 115 +++++++
 include/bpf_elf.h           |   2 +-
 include/utils.h             |   4 +
 lib/rt_names.c              |   5 +-
 tc/e_bpf.c                  |  30 +-
 tc/tc_bpf.c                 | 712 +++++++++++++++++++++++++++++++++-----------
 tc/tc_bpf.h                 |   1 +
 12 files changed, 823 insertions(+), 178 deletions(-)
 create mode 100644 etc/iproute2/bpf_pinning
 create mode 100644 examples/bpf/README
 create mode 100644 examples/bpf/bpf_cyclic.c
 create mode 100644 examples/bpf/bpf_graft.c
 create mode 100644 examples/bpf/bpf_tailcall.c

-- 
1.9.3
