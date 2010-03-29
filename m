From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP path MTU discovery
Date: Mon, 29 Mar 2010 23:29:12 +0200
Message-ID: <1269898152.1958.86.camel@edumazet-laptop>
References: <1269561751.2891.8.camel@ilion>
	 <877how25kx.fsf@basil.nowhere.org>	<4BB0DCF6.9020401@hp.com>
	 <20100329201431.GH20695@one.firstfloor.org>
	 <20100329205035.GA32656@laped.iglesias.mooo.com>  <4BB11510.9000302@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, Glen Turner <gdt@gdt.id.au>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:51689 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab0C2V3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 17:29:17 -0400
Received: by bwz1 with SMTP id 1so3928349bwz.21
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 14:29:15 -0700 (PDT)
In-Reply-To: <4BB11510.9000302@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 mars 2010 =C3=A0 14:01 -0700, Rick Jones a =C3=A9crit :

> I would get the alphabet soup completely garbled, but the DNS folks a=
re talking=20
> about EDNS (?) message sizes upwards of 4096 bytes - encryption/authe=
ntication=20
> and other angels being asked to dance on the head of the DNS pin are =
asking for=20
> more and more space in the messages.
>=20
> So, someone will have to blink somewhere - either DNS will have to go=
 TCP and=20
> *possibly* take RTT hits there depending on various patch streams, or=
 the IEEE=20
> will have to sanction jumbo frames and people deploy them widely, or =
it will=20
> have to become feasible to actually do the occasional IPv6 datagram=20
> fragmentation and get a timely retransmission out of a UDP applicatio=
n on a PMTU=20
> hit.
>=20

1) 4096 bytes UDP messages... well...
2) Using regular TCP for DNS servers... well...

I believe some guys were pushing TCPCT (Cookie Transactions) for this
case ( http://tools.ietf.org/html/draft-simpson-tcpct-00.html )

(That is, using an enhanced TCP for long DNS queries... but not only fo=
r
DNS...)



