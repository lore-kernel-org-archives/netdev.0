From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/5] BPF map value adjust fix
Date: Fri, 21 Jul 2017 00:00:20 +0200
Message-ID: <cover.1500586732.git.daniel@iogearbox.net>
Cc: ast@fb.com, ecree@solarflare.com, josef@toxicpanda.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45847 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934057AbdGTWEE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 18:04:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch in the series is the actual fix and the remaining
patches are just updates to selftests.

Thanks!

Daniel Borkmann (4):
  bpf: fix mixed signed/unsigned derived min/max value bounds
  bpf: allow to specify log level and reduce it for test_verifier
  bpf: fix up test cases with mixed signed/unsigned bounds
  bpf: more tests for mixed signed and unsigned bounds checks

Edward Cree (1):
  bpf: add test for mixed signed and unsigned bounds checks

 include/linux/bpf_verifier.h                |   1 +
 kernel/bpf/verifier.c                       | 108 ++++++-
 tools/lib/bpf/bpf.c                         |   4 +-
 tools/lib/bpf/bpf.h                         |   2 +-
 tools/testing/selftests/bpf/test_align.c    |   2 +-
 tools/testing/selftests/bpf/test_verifier.c | 480 +++++++++++++++++++++++++++-
 6 files changed, 574 insertions(+), 23 deletions(-)

-- 
1.9.3
