From: pablo@netfilter.org
Subject: [PATCH 0/2] netfilter fixes for net
Date: Thu, 22 Nov 2012 10:10:50 +0100
Message-ID: <1353575452-3127-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains two Netfilter fixes:

* Fix buffer overflow in the name of the timeout policy object
  in the cttimeout infrastructure, from Florian Westphal.

* Fix a bug in the hash set in case that IP ranges are
  specified, from Jozsef Kadlecsik.

You can pull these changes from:

git://1984.lsi.us.es/nf master

Thanks!

Florian Westphal (1):
  netfilter: cttimeout: fix buffer overflow

Jozsef Kadlecsik (1):
  netfilter: ipset: Fix range bug in hash:ip,port,net

 net/netfilter/ipset/ip_set_hash_ip.c        |    4 ++--
 net/netfilter/ipset/ip_set_hash_ipport.c    |    7 +++----
 net/netfilter/ipset/ip_set_hash_ipportip.c  |    7 +++----
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    7 +++++--
 net/netfilter/nfnetlink_cttimeout.c         |    3 ++-
 5 files changed, 15 insertions(+), 13 deletions(-)

-- 
1.7.10.4

