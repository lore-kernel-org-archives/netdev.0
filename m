From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: creating netdev queues on the fly?
Date: Fri, 11 Nov 2011 12:54:13 +0100
Message-ID: <1321012453.2548.37.camel@edumazet-laptop>
References: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
	 <CAGXE3d-_RFgW_zwfX2vTBe1psXmgoBFO5pd5cAgtYo=Jwpddhw@mail.gmail.com>
	 <7be02f26a67fac4c7448a74f1f17aa01@visp.net.lb>
	 <CAA93jw7ECQegWj6rpd48sbmDQUjorCYzXANXJSj0baHtxzC7EA@mail.gmail.com>
	 <1321009374.2548.31.camel@edumazet-laptop>
	 <CAA93jw7n1jYiWrnHOF0Zmzd0cVtadNhPSCpP5YqEdq_Q9opw5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys-ArQk2d8GGkZT5gTzvV8LJA@public.gmane.org>,
	Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAA93jw7n1jYiWrnHOF0Zmzd0cVtadNhPSCpP5YqEdq_Q9opw5A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 11 novembre 2011 =C3=A0 12:42 +0100, Dave Taht a =C3=A9crit=
 :

> More elegant to be sure. But for N you kind of need to do ewma betwee=
n
> aggregated transmission groups.
>=20

I speak at Class/Qdisc level. If each transmission group has its own
class [ I believe it should ], it should fit.


> I still don't 'get' how we can split out a stream based on a
> stationid, toss it in a queue to be further scheduled (my choice woul=
d
> be QFQ, btw), and then sanely de-schedule a burst of packets for that
> destination appropriate for that station's aggregation level and
> transmit rate using existing tc methods.
>=20

Right now its not possible since we dont have a feedback once a packet
is dequeued from qdisc. But it should be doable.

> I liked the callback idea discussed earlier for implementing a
> 'grouper' of this sort.
>=20
> That said I'm strongly encouraged by the dialog thus far on this thre=
ad.
>=20

=2E..

> and I assume that you are either making this syntax up or coding
> faster than emailing in some tree somewhere...
>=20

That because I prefer discussing on this before starting coding once
general idea is accepted.

Note this delay idea is not new, it already was mentioned on netdev som=
e
months ago.



--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
