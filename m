From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 09:46:20 +0200
Message-ID: <1272008780.7895.7746.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1271970199.7895.6482.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222323020.11449@ask.diku.dk>
	 <alpine.LSU.2.01.1004230922120.24961@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Patrick McHardy <kaber@trash.net>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1004230922120.24961@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 23 avril 2010 =C3=A0 09:23 +0200, Jan Engelhardt a =C3=A9cr=
it :
> On Thursday 2010-04-22 23:28, Jesper Dangaard Brouer wrote:
>=20
> > On Thu, 22 Apr 2010, Eric Dumazet wrote:
> >
> >> What exact version of kernel are you running ?
> >
> > 2.6.31.7-pvlan2G #3 SMP PREEMPT
> > 32-bit kernel with 2G kernel mem (you showed me that trick).
>=20
> Since when is enabling 2G a trick? :)
> There's CONFIG_VMSPLIT_2G (and 2G_OPT) for quite some time now.
>=20

Yes, when you know it, its not a trick anymore :)

Years ago, we had to manually change PAGE_OFFSET, and I remember some
machines with PAGE_OFFSET 0xA0000000  (1.5 GB LOWMEM),=20
or 0xB0000000 (1.25 GB), (PAE off)



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
