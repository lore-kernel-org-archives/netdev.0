From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/2] Two BPF fixes for s390
Date: Fri,  4 Aug 2017 14:20:53 +0200
Message-ID: <cover.1501848914.git.daniel@iogearbox.net>
Cc: holzheu@linux.vnet.ibm.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58273 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbdHDMU7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:20:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found while testing some other work touching JITs.

Thanks!

Daniel Borkmann (2):
  bpf, s390: fix jit branch offset related to ldimm64
  bpf, s390: fix build for libbpf and selftest suite

 arch/s390/net/bpf_jit_comp.c   | 3 ++-
 tools/build/feature/test-bpf.c | 2 ++
 tools/lib/bpf/bpf.c            | 2 ++
 3 files changed, 6 insertions(+), 1 deletion(-)

-- 
1.9.3
