From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: Tree for December 29 (netfilter build errors)
Date: Thu, 30 Dec 2010 18:07:25 +0100
Message-ID: <1293728845.7150.336.camel@edumazet-laptop>
References: <20101229130700.0ef93735.sfr@canb.auug.org.au>
	 <20101229085300.1ceac200.randy.dunlap@oracle.com>
	 <AANLkTin8Zc4wkx9BjD0vJSNdne8LVHx=JyeSC2YdKTKH@mail.gmail.com>
	 <AANLkTikPbKOQseJ8qfoSqv4XWgH5fjbg488jd6_Xv22E@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netfilter-devel@vger.kernel.org, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: sedat.dilek@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <AANLkTikPbKOQseJ8qfoSqv4XWgH5fjbg488jd6_Xv22E@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 30 d=C3=A9cembre 2010 =C3=A0 17:47 +0100, Sedat Dilek a =C3=A9=
crit :
> On Thu, Dec 30, 2010 at 3:18 AM, Changli Gao <xiaosuo@gmail.com> wrot=
e:
> > On Thu, Dec 30, 2010 at 12:53 AM, Randy Dunlap <randy.dunlap@oracle=
=2Ecom> wrote:
> >> On Wed, 29 Dec 2010 13:07:00 +1100 Stephen Rothwell wrote:
> >>
> >>> Hi all,
> >>>
> >>> Changes since 20101228:
> >>
> >>
> >> In file included from linux-next-20101229/net/ipv6/netfilter/nf_de=
frag_ipv6_hooks.c:22:
> >> linux-next-20101229/include/net/netfilter/nf_conntrack.h:94: error=
: field 'ct_general' has incomplete type
> >> linux-next-20101229/include/net/netfilter/nf_conntrack.h: In funct=
ion 'nf_ct_get':
> >> linux-next-20101229/include/net/netfilter/nf_conntrack.h:174: erro=
r: 'const struct sk_buff' has no member named 'nfct'
> >> linux-next-20101229/include/net/netfilter/nf_conntrack.h: In funct=
ion 'nf_ct_put':
> >> linux-next-20101229/include/net/netfilter/nf_conntrack.h:181: erro=
r: implicit declaration of function 'nf_conntrack_put'
> >>  CC      net/ipv6/exthdrs_core.o
> >> In file included from linux-next-20101229/include/net/netfilter/nf=
_conntrack_core.h:18,
> >>                 from linux-next-20101229/net/ipv6/netfilter/nf_def=
rag_ipv6_hooks.c:26:
> >> linux-next-20101229/include/net/netfilter/nf_conntrack_ecache.h: I=
n function 'nf_ct_ecache_ext_add':
> >> linux-next-20101229/include/net/netfilter/nf_conntrack_ecache.h:35=
: error: 'struct net' has no member named 'ct'
> >> In file included from linux-next-20101229/net/ipv6/netfilter/nf_de=
frag_ipv6_hooks.c:26:
> >> linux-next-20101229/include/net/netfilter/nf_conntrack_core.h: In =
function 'nf_conntrack_confirm':
> >> linux-next-20101229/include/net/netfilter/nf_conntrack_core.h:60: =
error: 'struct sk_buff' has no member named 'nfct'
> >> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c: In =
function 'nf_ct6_defrag_user':
> >> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:36: =
error: 'struct sk_buff' has no member named 'nfct'
> >> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:37: =
error: implicit declaration of function 'nf_ct_zone'
> >> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:37: =
error: 'struct sk_buff' has no member named 'nfct'
> >> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c: In =
function 'ipv6_defrag':
> >> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:60: =
error: 'struct sk_buff' has no member named 'nfct'
> >> linux-next-20101229/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:60: =
error: 'struct sk_buff' has no member named 'nfct'
> >> make[4]: *** [net/ipv6/netfilter/nf_defrag_ipv6_hooks.o] Error 1
> >> make[3]: *** [net/ipv6/netfilter] Error 2
> >>
> >>
> >>
> >
> > This bug has been already fixed in nf-next-2.6:
> > http://git.kernel.org/?p=3Dlinux/kernel/git/kaber/nf-next-2.6.git;a=
=3Dcommitdiff;h=3Dae90bdeaeac6b964b7a1e853a90a19f358a9ac20;hp=3Df1c7222=
95e029eace7960fc687efd5afd67dc555
> >
> > Thanks.
> >
> > --
> > Regards,
> > Changli Gao(xiaosuo@gmail.com)
> >
>=20
> Does not look like the nf-next-2.6 is triggered by linux-next... Does
> this tree passes net-next-2.6 and then enters linux-next?
>=20

Yes it does. Patrick is probably too busy right now to push fixes to
David.
