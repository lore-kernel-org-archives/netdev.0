From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 0/3] Minor tc/bpf updates
Date: Sat,  9 Apr 2016 00:32:02 +0200
Message-ID: <cover.1460153854.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39604 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbcDHWcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 18:32:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor updates to improve error reporting, add signatures
and recently introduced map flags attribute. Set is against
master branch.

Thanks!

Daniel Borkmann (3):
  tc, bpf: add new csum and tunnel signatures
  tc, bpf: further improve error reporting
  tc, bpf: add support for map pre/allocation

 examples/bpf/bpf_cyclic.c   |  9 ++++-
 examples/bpf/bpf_graft.c    |  8 +++-
 examples/bpf/bpf_prog.c     |  2 +
 examples/bpf/bpf_shared.c   |  8 +++-
 examples/bpf/bpf_tailcall.c | 29 ++++++++++++--
 include/bpf_api.h           | 52 ++++--------------------
 include/bpf_elf.h           |  1 +
 tc/tc_bpf.c                 | 98 +++++++++++++++++++++++++++++++++++----------
 tc/tc_bpf.h                 |  4 ++
 9 files changed, 138 insertions(+), 73 deletions(-)

-- 
1.9.3
