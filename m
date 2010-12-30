From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: linux-next: Tree for December 29 (netfilter build errors)
Date: Thu, 30 Dec 2010 10:18:43 +0800
Message-ID: <AANLkTin8Zc4wkx9BjD0vJSNdne8LVHx=JyeSC2YdKTKH@mail.gmail.com>
References: <20101229130700.0ef93735.sfr@canb.auug.org.au> <20101229085300.1ceac200.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netfilter-devel@vger.kernel.org, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101229085300.1ceac200.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 30, 2010 at 12:53 AM, Randy Dunlap <randy.dunlap@oracle.com=
> wrote:
> On Wed, 29 Dec 2010 13:07:00 +1100 Stephen Rothwell wrote:
>
>> Hi all,
>>
>> Changes since 20101228:
>
>
> In file included from linux-next-20101229/net/ipv6/netfilter/nf_defra=
g_ipv6_hooks.c:22:
> linux-next-20101229/include/net/netfilter/nf_conntrack.h:94: error: f=
ield 'ct_general' has incomplete type
> linux-next-20101229/include/net/netfilter/nf_conntrack.h: In function=
 'nf_ct_get':
> linux-next-20101229/include/net/netfilter/nf_conntrack.h:174: error: =
'const struct sk_buff' has no member named 'nfct'
> linux-next-20101229/include/net/netfilter/nf_conntrack.h: In function=
 'nf_ct_put':
> linux-next-20101229/include/net/netfilter/nf_conntrack.h:181: error: =
implicit declaration of function 'nf_conntrack_put'
> =A0CC =A0 =A0 =A0net/ipv6/exthdrs_core.o
> In file included from linux-next-20101229/include/net/netfilter/nf_co=
nntrack_core.h:18,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 from linux-next-20101229/net/ipv6/net=
filter/nf_defrag_ipv6_hooks.c:26:
> linux-next-20101229/include/net/netfilter/nf_conntrack_ecache.h: In f=
unction 'nf_ct_ecache_ext_add':
> linux-next-20101229/include/net/netfilter/nf_conntrack_ecache.h:35: e=
rror: 'struct net' has no member named 'ct'
> In file included from linux-next-20101229/net/ipv6/netfilter/nf_defra=
g_ipv6_hooks.c:26:
> linux-next-20101229/include/net/netfilter/nf_conntrack_core.h: In fun=
ction 'nf_conntrack_confirm':
> linux-next-20101229/include/net/netfilter/nf_conntrack_core.h:60: err=
or: 'struct sk_buff' has no member named 'nfct'
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c: In fun=
ction 'nf_ct6_defrag_user':
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:36: err=
or: 'struct sk_buff' has no member named 'nfct'
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:37: err=
or: implicit declaration of function 'nf_ct_zone'
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:37: err=
or: 'struct sk_buff' has no member named 'nfct'
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c: In fun=
ction 'ipv6_defrag':
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:60: err=
or: 'struct sk_buff' has no member named 'nfct'
> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:60: err=
or: 'struct sk_buff' has no member named 'nfct'
> make[4]: *** [net/ipv6/netfilter/nf_defrag_ipv6_hooks.o] Error 1
> make[3]: *** [net/ipv6/netfilter] Error 2
>
>
>

This bug has been already fixed in nf-next-2.6:
http://git.kernel.org/?p=3Dlinux/kernel/git/kaber/nf-next-2.6.git;a=3Dc=
ommitdiff;h=3Dae90bdeaeac6b964b7a1e853a90a19f358a9ac20;hp=3Df1c722295e0=
29eace7960fc687efd5afd67dc555

Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
