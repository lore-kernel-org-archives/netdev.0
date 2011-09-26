From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Mon, 26 Sep 2011 14:44:06 +0200
Message-ID: <1317041046.2557.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1316757739.2560.12.camel@edumazet-laptop>
	 <1316825745.1865.24.camel@mojatatu>
	 <1316978684.2531.7.camel@edumazet-laptop>
	 <1316999266.1865.35.camel@mojatatu>  <1316999597.1865.37.camel@mojatatu>
	 <1317025614.2557.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1317038443.1865.40.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Jim Gettys <jg@freedesktop.org>,
	Dave Taht <dave.taht@gmail.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63480 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359Ab1IZMn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 08:43:56 -0400
Received: by eya28 with SMTP id 28so3542088eya.19
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 05:43:54 -0700 (PDT)
In-Reply-To: <1317038443.1865.40.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 septembre 2011 =C3=A0 08:00 -0400, jamal a =C3=A9crit :
> On Mon, 2011-09-26 at 10:26 +0200, Eric Dumazet wrote:
>=20
> > This refers to additions to RFC 2481 : This was refined by RFC 3168=
, and
> > the retransmitted TCP packets requirement is part of the final RFC =
:
>=20
> Ah, yes - thats where it went.
>=20
> >=20
> > BTW, the ECN+ proposal (RFC 5562 :  Adding Explicit Congestion
> > Notification (ECN) Capability to TCP's SYN/ACK Packets) would allow=
 the
> > client (receiving SYNACK message with ECT flags) to set the TCP_ECN=
_SEEN
> > I added in my patch, allowing even the first (retransmitted) data p=
acket
> > to trigger quickack mode.
>=20
> Excellent ;->
> Are you going to add 5562 support?

I sent a private mail to Adam Langley this morning asking him if he
planned an official submission of a prior patch : =20
http://www.ietf.org/mail-archive/web/tcpm/current/msg03988.html

If Adam is too busy or not anymore interested, I would like to spend
some cycles on this.

Thanks
