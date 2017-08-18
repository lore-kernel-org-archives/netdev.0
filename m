From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] BPF inline improvements
Date: Sat, 19 Aug 2017 01:51:54 +0200
Message-ID: <cover.1503100047.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48199 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbdHRXwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:52:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First one makes htab inlining more robust wrt future jits and
second one inlines map in map lookups through map_gen_lookup()
callback.

Thanks!

Daniel Borkmann (2):
  bpf: improve htab inlining for future 32 bit jits
  bpf: inline map in map lookup functions for array and htab

 kernel/bpf/arraymap.c | 26 ++++++++++++++++++++++++++
 kernel/bpf/hashtab.c  | 27 +++++++++++++++++++++++++--
 2 files changed, 51 insertions(+), 2 deletions(-)

-- 
1.9.3
