From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: linux-next: Tree for December 29 (netfilter build errors)
Date: Thu, 30 Dec 2010 10:10:43 +0800
Message-ID: <4D1BEA23.5060800@cn.fujitsu.com>
References: <20101229130700.0ef93735.sfr@canb.auug.org.au> <20101229085300.1ceac200.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netfilter-devel@vger.kernel.org, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101229085300.1ceac200.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote, at 12/30/2010 12:53 AM:
> On Wed, 29 Dec 2010 13:07:00 +1100 Stephen Rothwell wrote:
> 
>> Hi all,
>>
>> Changes since 20101228:
> 
> 
> In file included from linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:22:
> linux-next-20101229/include/net/netfilter/nf_conntrack.h:94: error: field 'ct_general' has incomplete type
> linux-next-20101229/include/net/netfilter/nf_conntrack.h: In function 'nf_ct_get':
> linux-next-20101229/include/net/netfilter/nf_conntrack.h:174: error: 'const struct sk_buff' has no member named 'nfct'
> linux-next-20101229/include/net/netfilter/nf_conntrack.h: In function 'nf_ct_put':
> linux-next-20101229/include/net/netfilter/nf_conntrack.h:181: error: implicit declaration of function 'nf_conntrack_put'
>   CC      net/ipv6/exthdrs_core.o
> In file included from linux-next-20101229/include/net/netfilter/nf_conntrack_core.h:18,
>                  from linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:26:
> linux-next-20101229/include/net/netfilter/nf_conntrack_ecache.h: In function 'nf_ct_ecache_ext_add':
> linux-next-20101229/include/net/netfilter/nf_conntrack_ecache.h:35: error: 'struct net' has no member named 'ct'
> In file included from linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:26:
> linux-next-20101229/include/net/netfilter/nf_conntrack_core.h: In function 'nf_conntrack_confirm':
> linux-next-20101229/include/net/netfilter/nf_conntrack_core.h:60: error: 'struct sk_buff' has no member named 'nfct'
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c: In function 'nf_ct6_defrag_user':
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:36: error: 'struct sk_buff' has no member named 'nfct'
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:37: error: implicit declaration of function 'nf_ct_zone'
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:37: error: 'struct sk_buff' has no member named 'nfct'
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c: In function 'ipv6_defrag':
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:60: error: 'struct sk_buff' has no member named 'nfct'
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:60: error: 'struct sk_buff' has no member named 'nfct'
> make[4]: *** [net/ipv6/netfilter/nf_defrag_ipv6_hooks.o] Error 1
> make[3]: *** [net/ipv6/netfilter] Error 2

CONFIG_NF_DEFRAG_IPV6 depends on CONFIG_NF_CONNTRACK_IPV6 which depends on CONFIG_NF_CONNTRACK.
In you config file, CONFIG_NF_CONNTRACK_IPV6 and CONFIG_NF_CONNTRACK are not set, 
but CONFIG_NF_DEFRAG_IPV6 is set with 'y'. This is same with IPv4.

Selecting CONFIG_NF_CONNTRACK and CONFIG_NF_CONNTRACK_IPV6 may help to you.

-- 
Best Regards
-----
Shan Wei
