From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] net: xfrm: fix old-style declaration
Date: Thu, 16 Jun 2016 22:06:59 -0700 (PDT)
Message-ID: <20160616.220659.502030637416542450.davem@davemloft.net>
References: <20160616135020.3154461-1-arnd@arndb.de>
	<12896147.Nph51CCL66@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	dsa@cumulusnetworks.com, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <12896147.Nph51CCL66@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 16 Jun 2016 15:59:25 +0200

> Modern C standards expect the '__inline__' keyword to come before the return
> type in a declaration, and we get a couple of warnings for this with "make W=1"
> in the xfrm{4,6}_policy.c files:
> 
> net/ipv6/xfrm6_policy.c:369:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
>  static int inline xfrm6_net_sysctl_init(struct net *net)
> net/ipv6/xfrm6_policy.c:374:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
>  static void inline xfrm6_net_sysctl_exit(struct net *net)
> net/ipv4/xfrm4_policy.c:339:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
>  static int inline xfrm4_net_sysctl_init(struct net *net)
> net/ipv4/xfrm4_policy.c:344:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
>  static void inline xfrm4_net_sysctl_exit(struct net *net)
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
