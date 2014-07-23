From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/2] net: filter: split eBPF interpreter out of core networking
Date: Tue, 22 Jul 2014 23:01:57 -0700
Message-ID: <1406095319-3627-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:56339 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbaGWGCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 02:02:12 -0400
Received: by mail-pd0-f175.google.com with SMTP id r10so983663pdi.20
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 23:02:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I believe my recent set of RFC/patches [1] provided good visibility on where
I would like to take eBPF subsystem. These two trivial patches is a first step
in that direction:
patch 1 - mechanical split of eBPF interpreter out of filter.c
patch 2 - nominate myself as a maintainer for eBPF core pieces
In the foreseeable future eBPF patches will be going through net-next,
so put netdev as a primary mailing list

[1] git://git.kernel.org/pub/scm/linux/kernel/git/ast/bpf master

Alexei Starovoitov (2):
  net: filter: split filter.c into two files
  bpf: update MAINTAINERS entry

 MAINTAINERS         |    7 +
 kernel/Makefile     |    1 +
 kernel/bpf/Makefile |    1 +
 kernel/bpf/core.c   |  536 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/filter.c   |  511 ------------------------------------------------
 5 files changed, 545 insertions(+), 511 deletions(-)
 create mode 100644 kernel/bpf/Makefile
 create mode 100644 kernel/bpf/core.c

-- 
1.7.9.5
