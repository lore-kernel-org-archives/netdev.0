From: pablo@netfilter.org
Subject: [PATCH 0/2] late fixes for netfilter's ctnetlink
Date: Sat, 24 Dec 2011 19:52:46 +0100
Message-ID: <1324752768-5853-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi Dave,

These are a couple of late fixes for ctnetlink.

You can pull them from:

git://1984.lsi.us.es/net nf

Please, apply!
Thanks.

Pablo Neira Ayuso (2):
  netfilter: ctnetlink: fix return value of ctnetlink_get_expect()
  netfilter: ctnetlink: fix scheduling while atomic if helper is
    autoloaded

 net/netfilter/nf_conntrack_netlink.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

-- 
1.7.2.5

