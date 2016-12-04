From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/3] Minor BPF cleanups and digest
Date: Sun,  4 Dec 2016 23:19:38 +0100
Message-ID: <cover.1480889473.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40037 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbcLDWTo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 17:19:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First two patches are minor cleanups, and the third one adds
a prog digest. For details, please see individual patches.
After this one, I have a set with tracepoint support that makes
use of this facility as well.

Thanks!

Daniel Borkmann (3):
  bpf: remove type arg from __is_valid_{,xdp_}access
  bpf, cls: consolidate prog deletion path
  bpf: add prog_digest and expose it via fdinfo/netlink

 include/linux/bpf.h                |  1 +
 include/linux/filter.h             |  7 +++-
 include/uapi/linux/pkt_cls.h       |  1 +
 include/uapi/linux/tc_act/tc_bpf.h |  1 +
 kernel/bpf/core.c                  | 65 ++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c               | 24 +++++++++++++-
 kernel/bpf/verifier.c              |  2 ++
 net/core/filter.c                  | 15 ++++-----
 net/sched/act_bpf.c                |  9 ++++++
 net/sched/cls_bpf.c                | 38 ++++++++++++----------
 10 files changed, 135 insertions(+), 28 deletions(-)

-- 
1.9.3
