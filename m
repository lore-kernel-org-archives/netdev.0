From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/3] BPF range marking improvements for meta data
Date: Wed,  1 Nov 2017 23:58:08 +0100
Message-ID: <cover.1509576758.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55616 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754732AbdKAW60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 18:58:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The set contains improvements for direct packet access range
markings related to data_meta pointer and test cases for all
such access patterns that the verifier matches on.

Thanks!

Daniel Borkmann (3):
  bpf: minor cleanups after merge
  bpf: also improve pattern matches for meta access
  bpf: add test cases to bpf selftests to cover all meta tests

 kernel/bpf/verifier.c                       | 167 +++++----
 tools/testing/selftests/bpf/test_verifier.c | 552 +++++++++++++++++++++++++---
 2 files changed, 594 insertions(+), 125 deletions(-)

-- 
1.9.3
