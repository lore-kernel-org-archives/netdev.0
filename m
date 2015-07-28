From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/5] s390/bpf: recache skb->data/hlen for skb_vlan_push/pop
Date: Tue, 28 Jul 2015 16:09:55 +0200
Message-ID: <1438092600-16221-1-git-send-email-holzheu@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:45584 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301AbbG1OKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 10:10:32 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
	Tue, 28 Jul 2015 15:10:28 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here the s390 backend for Alexei's patch 4e10df9a60d9 ("bpf: introduce
bpf_skb_vlan_push/pop() helpers") plus two bugfixes and two minor
improvements.

The first patch "s390/bpf: clear correct BPF accumulator register" will
also go upstream via Martin's "fixes" branch.

Ok for you?

Regards,
Michael

Michael Holzheu (5):
  s390/bpf: clear correct BPF accumulator register
  s390/bpf: Fix multiple macro expansions
  s390/bpf: increase BPF_SIZE_MAX
  s390/bpf: Only clear A and X for converted BPF programs
  s390/bpf: recache skb->data/hlen for skb_vlan_push/pop

 arch/s390/net/bpf_jit.h      |  5 ++-
 arch/s390/net/bpf_jit_comp.c | 91 +++++++++++++++++++++++---------------------
 2 files changed, 52 insertions(+), 44 deletions(-)

-- 
2.3.8
