From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 21 Jun 2017 11:47:30 +1000
Message-ID: <20170621114730.4e8724fd@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Serhey Popovych <serhe.popovych@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/core/rtnetlink.c

between commit:

  db833d40ad32 ("rtnetlink: add IFLA_GROUP to ifla_policy")

from the net tree and commit:

  3d3ea5af5c0b ("rtnl: Add support for netdev event to link messages")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/core/rtnetlink.c
index 467a2f4510a7,3aa57848a895..000000000000
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@@ -1469,7 -1519,7 +1520,8 @@@ static const struct nla_policy ifla_pol
  	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
  	[IFLA_PROTO_DOWN]	= { .type = NLA_U8 },
  	[IFLA_XDP]		= { .type = NLA_NESTED },
 +	[IFLA_GROUP]		= { .type = NLA_U32 },
+ 	[IFLA_EVENT]		= { .type = NLA_U32 },
  };
  
  static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
