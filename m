From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/3] Two BPF fixes for range marking
Date: Sat, 21 Oct 2017 02:34:20 +0200
Message-ID: <cover.1508545543.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47358 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752633AbdJUAew (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 20:34:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The set contains two fixes for direct packet access range
markings and test cases for all direct packet access patterns
that the verifier matches on.

They are targeted for net tree, note that once net gets merged
into net-next, there will be a minor merge conflict due to
signature change of the function find_good_pkt_pointers() as
well as data_meta patterns present in net-next tree. You can
just add bool false to the data_meta patterns and I will
follow-up with properly converting the patterns for data_meta
in a similar way.

Thanks a lot!

Daniel Borkmann (3):
  bpf: fix off by one for range markings with L{T,E} patterns
  bpf: fix pattern matches for direct packet access
  bpf: add test cases to bpf selftests to cover all access tests

 kernel/bpf/verifier.c                       |  57 +++-
 tools/testing/selftests/bpf/test_verifier.c | 480 ++++++++++++++++++++++++++++
 2 files changed, 525 insertions(+), 12 deletions(-)

-- 
1.9.3
