From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] bpf/filter updates
Date: Wed, 11 Dec 2013 23:43:42 +0100
Message-ID: <1386801825-15388-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7974 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996Ab3LKWnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 17:43:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds just two minimal helper tools that complement the
already available bpf_jit_disasm and complete BPF tooling; plus
it adds and an extensive documentation update of filter.txt.

Please see individual descriptions for details.

Thanks !

Daniel Borkmann (3):
  filter: bpf_dbg: add minimal bpf debugger
  filter: bpf_asm: add minimal bpf asm tool
  filter: doc: improve BPF documentation

 Documentation/networking/filter.txt |  608 +++++++++++++--
 tools/net/Makefile                  |   23 +-
 tools/net/bpf_asm.c                 |   52 ++
 tools/net/bpf_dbg.c                 | 1404 +++++++++++++++++++++++++++++++++++
 tools/net/bpf_exp.l                 |  143 ++++
 tools/net/bpf_exp.y                 |  749 +++++++++++++++++++
 6 files changed, 2930 insertions(+), 49 deletions(-)
 create mode 100644 tools/net/bpf_asm.c
 create mode 100644 tools/net/bpf_dbg.c
 create mode 100644 tools/net/bpf_exp.l
 create mode 100644 tools/net/bpf_exp.y

-- 
1.8.3.1
