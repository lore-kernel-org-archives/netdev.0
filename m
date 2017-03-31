From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/3] BPF fixes on map_value_adj reg types
Date: Fri, 31 Mar 2017 02:24:01 +0200
Message-ID: <cover.1490918592.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@fb.com, jbacik@fb.com, kafai@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46182 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932701AbdCaAYS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 20:24:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds two fixes for map_value_adj register type in the
verifier and user space tests along with them for the BPF self
test suite. For details, please see individual patches.

Thanks!

Daniel Borkmann (3):
  bpf, verifier: fix alu ops against map_value{,_adj} register types
  bpf, verifier: fix rejection of unaligned access checks for map_value_adj
  bpf: add various verifier test cases for self-tests

 kernel/bpf/verifier.c                       |  59 +++---
 tools/include/linux/filter.h                |  10 ++
 tools/testing/selftests/bpf/Makefile        |   9 +-
 tools/testing/selftests/bpf/test_verifier.c | 270 +++++++++++++++++++++++++++-
 4 files changed, 322 insertions(+), 26 deletions(-)

-- 
1.9.3
