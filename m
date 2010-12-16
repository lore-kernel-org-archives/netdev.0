From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible regression: Packet drops during iptables calls
Date: Thu, 16 Dec 2010 15:13:41 +0100
Message-ID: <1292508821.2883.156.camel@edumazet-laptop>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>,
	Steven Rostedt <srostedt@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292508266.31289.12.camel@firesoul.comx.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 15:04 +0100, Jesper Dangaard Brou=
er a
=C3=A9crit :

> Now I just need to calculate, how large a NIC buffer I need to buffer
> 3.125 ms at 1Gbit/s.
>=20
>  3.125 ms *  1Gbit/s =3D 390625 bytes
>=20
> Can this be correct?
>=20
> How much buffer does each queue have in the 82576 NIC?
> (Hope Alexander Duyck can answer this one?)
>=20

Worst case is if you receive very small frames, because 3.125 ms is
about 5000 frames at 1Gbit/s



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
