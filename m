From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 0/2] Minor BPF updates
Date: Fri, 21 Jul 2017 21:13:05 +0200
Message-ID: <cover.1500663605.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58987 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753527AbdGUTNW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 15:13:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two minor updates to the BPF code, first one makes use of the
recently exposed owner_jited in fdinfo to report whether a
load issue related to tail calls occured, and second one fixes
up custom mount of bpf fs when passed via env.

Thanks!

Daniel Borkmann (2):
  bpf: improve error reporting around tail calls
  bpf: fix mnt path when from env

 lib/bpf.c | 281 +++++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 214 insertions(+), 67 deletions(-)

-- 
1.9.3
