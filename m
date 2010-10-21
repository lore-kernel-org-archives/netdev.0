From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/9] tproxy: split off ipv6 defragmentation to a
 separate module
Date: Fri, 22 Oct 2010 00:19:18 +0200
Message-ID: <1287699558.2607.5.camel@edumazet-laptop>
References: <20101021104709.5192.31249.stgit@este.odu>
	 <20101021104709.5192.64336.stgit@este.odu>  <4CC02456.4050301@trash.net>
	 <1287661385.13326.45.camel@este.odu>  <4CC0486D.60703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: KOVACS Krisztian <hidden@balabit.hu>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CC0486D.60703@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 21 octobre 2010 =C3=A0 16:04 +0200, Patrick McHardy a =C3=A9cr=
it :
> Am 21.10.2010 13:43, schrieb KOVACS Krisztian:
> > tproxy: split off ipv6 defragmentation to a separate module
> >    =20
> >     Like with IPv4, TProxy needs IPv6 defragmentation but does not
> >     require connection tracking. Since defragmentation was coupled
> >     with conntrack, I split off the two, creating an nf_defrag_ipv6=
 module,
> >     similar to the already existing nf_defrag_ipv4.
>=20
> Applied, thanks.

Hmm...

CONFIG_IPV6=3Dm
CONFIG_NETFILTER_TPROXY=3Dm


  MODPOST 201 modules
ERROR: "nf_defrag_ipv6_enable" [net/netfilter/xt_TPROXY.ko] undefined!
ERROR: "ipv6_find_hdr" [net/netfilter/xt_TPROXY.ko] undefined!

Sorry, it's late here, I wont fix this ;)



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
