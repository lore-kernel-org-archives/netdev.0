From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 0/3] Implement delete for BPF LPM trie
Date: Mon, 18 Sep 2017 15:30:54 -0400
Message-ID: <20170918193057.37644-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:43846 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdIRTa7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:30:59 -0400
Received: by mail-qt0-f171.google.com with SMTP id i50so1672543qtf.0
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:30:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This was previously left as a TODO.  Add the implementation and
extend the test to cover it.

Craig Gallek (3):
  bpf: Implement map_delete_elem for BPF_MAP_TYPE_LPM_TRIE
  bpf: Add uniqueness invariant to trivial lpm test implementation
  bpf: Test deletion in BPF_MAP_TYPE_LPM_TRIE

 kernel/bpf/lpm_trie.c                      |  80 +++++++++++-
 tools/testing/selftests/bpf/test_lpm_map.c | 201 ++++++++++++++++++++++++++++-
 2 files changed, 273 insertions(+), 8 deletions(-)

-- 
2.14.1.690.gbb1197296e-goog
