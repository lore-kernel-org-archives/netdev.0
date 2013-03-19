From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/4] net: filter: BPF updates
Date: Tue, 19 Mar 2013 14:28:23 +0100
Message-ID: <cover.1363699285.git.dborkman@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jasowang@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47585 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755362Ab3CSN2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 09:28:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds i) an ancillary operation to the BPF engine and ii) a
BPF JIT image disassembler in order to verify or debug the BPF JIT
compilers under arch/*/net/.

Daniel Borkmann (4):
  flow_keys: include thoff into flow_keys for later usage
  net: flow_dissector: add __skb_get_poff to get a start offset to payload
  filter: add ANC_PAY_OFFSET instruction for loading payload start offset
  filter: add minimal BPF JIT emitted image disassembler

 include/linux/filter.h      |   1 +
 include/linux/skbuff.h      |   2 +
 include/net/flow_keys.h     |   1 +
 include/uapi/linux/filter.h |   3 +-
 net/core/filter.c           |   5 +
 net/core/flow_dissector.c   |  62 ++++++++++++-
 net/sched/sch_choke.c       |   4 +-
 scripts/bpf_jit_disasm.c    | 216 ++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 290 insertions(+), 4 deletions(-)
 create mode 100644 scripts/bpf_jit_disasm.c

-- 
1.7.11.7
