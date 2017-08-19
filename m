From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 0/2] BPF inline improvements
Date: Sat, 19 Aug 2017 03:12:44 +0200
Message-ID: <cover.1503104831.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57139 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751017AbdHSBMw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 21:12:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First one makes htab inlining more robust wrt future jits and
second one inlines map in map lookups through map_gen_lookup()
callback.

Thanks!

v1 -> v2:
  - BITS_PER_LONG guard in patch 1
  - BPF_EMIT_CALL is on __htab_map_lookup_elem

Daniel Borkmann (2):
  bpf: make htab inlining more robust wrt assumptions
  bpf: inline map in map lookup functions for array and htab

 kernel/bpf/arraymap.c | 26 ++++++++++++++++++++++++++
 kernel/bpf/hashtab.c  | 17 +++++++++++++++++
 kernel/bpf/verifier.c |  6 +++++-
 3 files changed, 48 insertions(+), 1 deletion(-)

-- 
1.9.3
