From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] couple of reasm fixes
Date: Tue,  5 Nov 2013 12:02:10 +0100
Message-ID: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, coreteam@netfilter.org, fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Couple of patches to fix issues which were found on
TPROXY vs. IPV6 frag packets use cases.

Jiri Pirko (3):
  move skb_nfct_reasm into skbuff.h
  netfilter: ip6_tables: use reasm skb for matching
  fix skb_morph to preserve skb->sk and skb->destructor pointers

 include/linux/skbuff.h          | 11 +++++++++++
 include/net/ip_vs.h             |  8 --------
 net/core/skbuff.c               | 44 +++++++++++++++++++++++++----------------
 net/ipv6/netfilter/ip6_tables.c |  8 ++++++--
 net/netfilter/ipvs/ip_vs_core.c |  1 +
 5 files changed, 45 insertions(+), 27 deletions(-)

-- 
1.8.3.1

