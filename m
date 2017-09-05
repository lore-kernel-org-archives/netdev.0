From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 0/2] Two minor BPF updates
Date: Tue,  5 Sep 2017 02:24:30 +0200
Message-ID: <cover.1504570627.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49477 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754042AbdIEAYq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 20:24:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two minor updates including a small cleanup for dumping
the trace pipe and one for consolidating prog dumps for
tc and xdp to use bpf_prog_info_by_fd() when possible.

Thanks!

Daniel Borkmann (2):
  bpf: minor cleanups for bpf_trace_pipe
  bpf: consolidate dumps to use bpf_dump_prog_info

 include/bpf_util.h |  2 +-
 ip/ipaddress.c     |  6 ++++--
 ip/iplink_xdp.c    | 19 +++++++++++++++----
 ip/xdp.h           |  2 +-
 lib/bpf.c          | 31 ++++++++++++++++++-------------
 tc/f_bpf.c         |  8 ++++----
 tc/m_bpf.c         |  8 ++++----
 7 files changed, 47 insertions(+), 29 deletions(-)

-- 
1.9.3
