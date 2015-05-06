From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/4] BPF updates
Date: Wed,  6 May 2015 16:12:26 +0200
Message-ID: <cover.1430908145.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, keescook@chromium.org, nschichan@freebox.fr,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59823 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbbEFOMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 10:12:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set gets rid of BPF special handling in seccomp filter preparation
and provides generic infrastructure from BPF side, which eventually also
allows for classic BPF JITs to add support for seccomp filters.

Daniel Borkmann (2):
  net: filter: add __GFP_NOWARN flag for larger kmem allocs
  seccomp, filter: add and use bpf_prog_create_from_user from seccomp

Nicolas Schichan (2):
  net: filter: add a callback to allow classic post-verifier transformations
  seccomp: simplify seccomp_prepare_filter and reuse bpf_prepare_filter

 include/linux/filter.h | 10 +++---
 kernel/seccomp.c       | 70 +++++++++---------------------------------
 net/core/filter.c      | 82 ++++++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 91 insertions(+), 71 deletions(-)

-- 
1.9.3
