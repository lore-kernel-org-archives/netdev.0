From: kaber@trash.net
Subject: [PATCH 00/80] netfilter: netfilter update
Date: Thu, 20 Jan 2011 08:58:01 +0100
Message-ID: <1295510282-16860-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[resend of the previous pull request, I've added Jan's fix to my tree,
 just resending the new patch instead of the entire batch]

following is a first batch of netfilter patches for 2.6.39, containing:

- cleanups and removal of atomic operations from Changli Gao

- RCU annotations, removal of atomic operations and cleanups from Eric

- a new queue bypass option for nfnetlink_queue from Florian Westphal

- arp_tables support for xt_CLASSIFY from Frederic Leroy

- a new backup protocol for IPVS from and Schillstrom

- IPVS netns support from Hans Schillstrom

- type and header cleanups from Jan

- missing module aliases from Jan

- a new SNMP conntrack helper from Jiri Olsa

- optional timestamping for conntrack entries to simplify userspace IPFIX,
  implementations, from Pablo

- a new AUDIT target for logging packets through the audit framework,
  from Thomas

- Improvements for the IPVS persistence engine from Simon

ipset from Jozsef will follow soon, once I'm done reviewing it.

Please pull from

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!
