From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master resend 0/4] Minor BPF updates on frontend
Date: Sun,  7 Feb 2016 02:11:49 +0100
Message-ID: <cover.1454806938.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51788 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbcBGBMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 20:12:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Couple of minor updates on tc frontend.

Resending with no changes and with John's Acked-by kept, orignal
version got set to 'Changes requested' by mistake.

Thanks!

Daniel Borkmann (4):
  tc, bpf, examples: further bpf_api improvements
  tc, bpf: improve verifier logging
  tc, bpf: give some more hints wrt false relos
  tc, bpf: use bind/type macros from gelf

 examples/bpf/bpf_cyclic.c   |   4 +-
 examples/bpf/bpf_graft.c    |  13 +---
 examples/bpf/bpf_prog.c     |  26 +++----
 examples/bpf/bpf_shared.c   |   3 +-
 examples/bpf/bpf_tailcall.c |  12 +--
 include/bpf_api.h           |  56 ++++++++++++--
 tc/tc_bpf.c                 | 173 +++++++++++++++++++++++++++++++-------------
 tc/tc_bpf.h                 |   1 -
 8 files changed, 191 insertions(+), 97 deletions(-)

-- 
1.9.3
