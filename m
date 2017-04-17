From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/2] Two BPF fixes
Date: Mon, 17 Apr 2017 03:12:05 +0200
Message-ID: <cover.1492390940.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, kubakici@wp.pl,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51326 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757057AbdDQBMR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 21:12:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The set fixes cb_access and xdp_adjust_head bits in struct bpf_prog,
that are used for requirement checks on the program rather than f.e.
heuristics. Thus, for tail calls, we cannot make any assumptions and
are forced to set them.

Thanks!

Daniel Borkmann (2):
  bpf: fix cb access in socket filter programs on tail calls
  bpf: fix checking xdp_adjust_head on tail calls

 kernel/bpf/syscall.c | 8 ++++++++
 1 file changed, 8 insertions(+)

-- 
1.9.3
