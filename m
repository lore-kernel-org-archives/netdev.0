From: pablo@netfilter.org
Subject: [PATCH 0/2] Netfilter updates for 3.5-rc5
Date: Fri,  6 Jul 2012 13:39:37 +0200
Message-ID: <1341574779-3373-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patches provide two fixes:

* One to get the timeout special parameter for the SET target back working
  (this was introduced while trying to fix another bug in 3.4) from
  Jozsef Kadlecsik.

* One crash fix if containers and nf_conntrack are used reported by Hans
  Schillstrom by myself.

You can pull these fixes from:

git://1984.lsi.us.es/nf master

Thanks.

little notice: I forgot to add my Signed-off-by while manually applying
Jozsef's patch, sorry. It was a bit too late to fix, I already pushed out
to my master branch.

Jozsef Kadlecsik (1):
  netfilter: ipset: timeout fixing bug broke SET target special timeout value

Pablo Neira Ayuso (1):
  netfilter: nf_ct_ecache: fix crash with multiple containers, one shutting down

 include/net/netfilter/nf_conntrack_ecache.h |    2 +-
 net/netfilter/xt_set.c                      |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

-- 
1.7.10

