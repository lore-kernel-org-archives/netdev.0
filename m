From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 0/2] bpf: introduce bpf_skb_vlan_push/pop() helpers
Date: Mon, 20 Jul 2015 20:34:17 -0700
Message-ID: <1437449659-23765-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33182 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbGUDe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 23:34:26 -0400
Received: by pdbnt7 with SMTP id nt7so40950609pdb.0
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 20:34:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let TC+eBPF programs call skb_vlan_push/pop via helpers.

v1->v2:
- reworded commit log to better explain correctness of re-caching
  and fixed comparison of mixed endiannes (suggested by Eric)

Alexei Starovoitov (2):
  bpf: introduce bpf_skb_vlan_push/pop() helpers
  test_bpf: add bpf_skb_vlan_push/pop() tests

 arch/s390/net/bpf_jit_comp.c |    4 ++
 arch/x86/net/bpf_jit_comp.c  |   80 ++++++++++++++++++----------------
 include/linux/bpf.h          |    2 +
 include/linux/filter.h       |    1 +
 include/uapi/linux/bpf.h     |    2 +
 kernel/bpf/core.c            |    1 +
 lib/test_bpf.c               |   98 ++++++++++++++++++++++++++++++++++++++++--
 net/core/filter.c            |   50 +++++++++++++++++++++
 8 files changed, 197 insertions(+), 41 deletions(-)

-- 
1.7.9.5
