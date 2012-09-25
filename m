From: pablo@netfilter.org
Subject: [PATCH] netfilter fix for 3.6-rc7
Date: Wed, 26 Sep 2012 01:34:10 +0200
Message-ID: <1348616051-5694-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

If time allows, I'd appreciate if you can take the following fix
for the xt_limit match.

As Jan indicates, random things may occur while using the xt_limit
match due to use of uninitialized memory.

You can pull this change from:

git://1984.lsi.us.es/nf master

Thanks!

Jan Engelhardt (1):
  netfilter: xt_limit: have r->cost != 0 case work

 net/netfilter/xt_limit.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

-- 
1.7.10.4

