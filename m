From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 0/3] BPF updates
Date: Mon, 17 Jul 2017 17:18:49 +0200
Message-ID: <cover.1500301061.git.daniel@iogearbox.net>
Cc: kafai@fb.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48042 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdGQPTA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 11:19:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Couple of misc updates related to BPF. First removes a BPF sample
that is long legacy (pre BPF fs times), then we add support for the
loader to be able to take care of map in map, and last but not least
we dump id and whether prog was jited in tc filter show for cls/act
BPF programs.

The set is intended for -master branch _after_ the -net-next branch
got merged into -master branch.

Thanks!

Daniel Borkmann (3):
  bpf: remove obsolete samples
  bpf: support loading map in map from obj
  bpf: dump id/jited info for cls/act programs

 examples/bpf/bpf_agent.c      | 258 ----------------------
 examples/bpf/bpf_map_in_map.c |  56 +++++
 examples/bpf/bpf_prog.c       | 501 ------------------------------------------
 examples/bpf/bpf_shared.h     |  22 --
 examples/bpf/bpf_sys.h        |  23 --
 include/bpf_elf.h             |   2 +
 include/bpf_util.h            |   2 +
 lib/bpf.c                     | 205 ++++++++++++++++-
 tc/f_bpf.c                    |   3 +
 tc/m_bpf.c                    |   3 +
 10 files changed, 261 insertions(+), 814 deletions(-)
 delete mode 100644 examples/bpf/bpf_agent.c
 create mode 100644 examples/bpf/bpf_map_in_map.c
 delete mode 100644 examples/bpf/bpf_prog.c
 delete mode 100644 examples/bpf/bpf_shared.h
 delete mode 100644 examples/bpf/bpf_sys.h

-- 
1.9.3
