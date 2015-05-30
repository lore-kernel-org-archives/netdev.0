From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/3] s390/bpf: implement bpf_tail_call JIT support
Date: Sat, 30 May 2015 10:42:08 -0700
Message-ID: <1433007731-16992-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35781 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038AbbE3RmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 13:42:21 -0400
Received: by padjw17 with SMTP id jw17so7292587pad.2
        for <netdev@vger.kernel.org>; Sat, 30 May 2015 10:42:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set is for net-next tree.

Patch 3 adds bpf_tail_call() support for s390x JIT. It has
a dependency on patches 1 and 2 that will also be submitted
to stable via Martin Schwidefsky.

Michael Holzheu (3):
  s390/bpf: fix stack allocation
  s390/bpf: fix bpf frame pointer setup
  s390/bpf: implement bpf_tail_call() helper

 arch/s390/net/bpf_jit.h      |   12 ++++-
 arch/s390/net/bpf_jit_comp.c |  117 +++++++++++++++++++++++++++++++++++++++---
 2 files changed, 121 insertions(+), 8 deletions(-)

-- 
1.7.9.5
