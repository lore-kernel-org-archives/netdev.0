From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] Add BPF numa id helper
Date: Fri, 21 Oct 2016 00:30:25 +0200
Message-ID: <cover.1477002095.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33120 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753618AbcJTWaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 18:30:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds a helper for retrieving current numa node
id and a test case for SO_REUSEPORT.

Thanks!

Daniel Borkmann (2):
  bpf: add helper for retrieving current numa node id
  reuseport, bpf: add test case for bpf_get_numa_node_id

 include/linux/bpf.h                              |   1 +
 include/uapi/linux/bpf.h                         |   6 +
 kernel/bpf/helpers.c                             |  12 ++
 kernel/trace/bpf_trace.c                         |   2 +
 net/core/filter.c                                |   2 +
 tools/testing/selftests/net/.gitignore           |   1 +
 tools/testing/selftests/net/Makefile             |  11 +-
 tools/testing/selftests/net/reuseport_bpf_numa.c | 255 +++++++++++++++++++++++
 8 files changed, 286 insertions(+), 4 deletions(-)
 create mode 100644 tools/testing/selftests/net/reuseport_bpf_numa.c

-- 
1.9.3
