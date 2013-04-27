From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/18] netfilter updates for net-next
Date: Sat, 27 Apr 2013 20:58:05 +0200
Message-ID: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains relevant updates for the Netfilter
tree, they are:

* Enhancements for ipset: Add the counter extension for sets, this
  information can be used from the iptables set match, to change
  the matching behaviour. Jozsef required to add the extension
  infrastructure and moved the existing timeout support upon it.

* Enhancements for performance boosting in nfnetlink_queue: Add new
  configuration flags that allows user-space to receive big packets (GRO)
  and to disable checksumming calculation. This were proposed by Eric
  Dumazet during the Netfilter Workshop 2013 in Copenhagen. Florian
  Westphal was kind enough to find the time to materialize the proposal.

* A sparse fix from Simon, he noticed it in the SCTP NAT helper, the fix
  required a change in the interface of sctp_end_cksum.

Let me know if we're still in time to get this into net-next. Thanks!

The following changes since commit 37fe0660981d7a1577409226f77554c2c5123e27:

  net: fix address check in rtnl_fdb_del (2013-04-25 04:14:08 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 3a44129aabea6813dc05b829c552fd98b3ab0b68:

  sctp: Correct type and usage of sctp_end_cksum() (2013-04-27 19:55:00 +0200)

----------------------------------------------------------------
Florian Westphal (4):
      netfilter: nf_queue: move device refcount bump to extra function
      netfilter: move skb_gso_segment into nfnetlink_queue module
      netfilter: nfnetlink_queue: add skb info attribute
      netfilter: nfnetlink_queue: avoid expensive gso segmentation and checksum fixup

Jozsef Kadlecsik (13):
      netfilter: ipset: Make possible to test elements marked with nomatch
      netfilter: ipset: Move often used IPv6 address masking function to header file
      netfilter: ipset: Introduce extensions to elements in the core
      netfilter: ipset: Unified bitmap type generation
      netfilter: ipset: Bitmap types using the unified code base
      netfilter: ipset: Unified hash type generation
      netfilter: ipset: Hash types using the unified code base
      netfilter: ipset: list:set type using the extension interface
      netfilter: ipset: Introduce the counter extension in the core
      netfilter: ipset: The bitmap types with counter support
      netfilter: ipset: The hash types with counter support
      netfilter: ipset: The list:set type with counter support
      netfilter: ipset: set match: add support to match the counters

Simon Horman (1):
      sctp: Correct type and usage of sctp_end_cksum()

