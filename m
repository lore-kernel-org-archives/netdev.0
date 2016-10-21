From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 0/2] Add BPF numa id helper
Date: Fri, 21 Oct 2016 12:46:32 +0200
Message-ID: <cover.1477043972.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33304 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754035AbcJUKqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 06:46:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds a helper for retrieving current numa node
id and a test case for SO_REUSEPORT.

Thanks!

v1 -> v2:
  - Missed __weak definition when bpf syscall is not enabled, sorry.
  - Rest as is.

Daniel Borkmann (2):
  bpf: add helper for retrieving current numa node id
  reuseport, bpf: add test case for bpf_get_numa_node_id

 include/linux/bpf.h                              |   1 +
 include/uapi/linux/bpf.h                         |   6 +
 kernel/bpf/core.c                                |   1 +
 kernel/bpf/helpers.c                             |  12 ++
 kernel/trace/bpf_trace.c                         |   2 +
 net/core/filter.c                                |   2 +
 tools/testing/selftests/net/.gitignore           |   1 +
 tools/testing/selftests/net/Makefile             |  11 +-
 tools/testing/selftests/net/reuseport_bpf_numa.c | 255 +++++++++++++++++++++++
 9 files changed, 287 insertions(+), 4 deletions(-)
 create mode 100644 tools/testing/selftests/net/reuseport_bpf_numa.c

-- 
1.9.3
