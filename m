From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master v2 0/2] Minor BPF updates
Date: Sun, 23 Jul 2017 01:22:17 +0200
Message-ID: <1500765739-10681-1-git-send-email-daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43140 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbdGVXW2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 19:22:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two minor updates to the BPF code, first one makes use of the
recently exposed owner_jited in fdinfo to report whether a
load issue related to tail calls occured, and second one fixes
up custom mount of bpf fs when passed via env.

Thanks!

v1 -> v2:
  - Moved bpf_derive_prog_from_fdinfo() under HAVE_ELF.
  - Rest as is.

Daniel Borkmann (2):
  bpf: improve error reporting around tail calls
  bpf: fix mnt path when from env

 lib/bpf.c | 281 +++++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 214 insertions(+), 67 deletions(-)

-- 
2.9.3
