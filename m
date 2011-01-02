From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 02 Jan 2011 12:57:56 +0100
Message-ID: <1293969476.29869.2.camel@wall-e>
References: <1293918276-28773-1-git-send-email-stefani@seibold.net>
	 <1293920601.2535.64.camel@edumazet-laptop>
	 <1293967023.29525.16.camel@wall-e>
	 <1293967996.2535.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293967996.2535.76.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, den 02.01.2011, 12:33 +0100 schrieb Eric Dumazet:
> Le dimanche 02 janvier 2011 =E0 12:17 +0100, Stefani Seibold a =E9cri=
t :
> > Am Samstag, den 01.01.2011, 23:23 +0100 schrieb Eric Dumazet:
>=20
> > > 3) I see UDPLITE references in your code. Are you sure UDPCP prot=
ocol
> > > can really work on top of UDPLITE ? I think not, so please remove=
 dead
> > > code.
> > >=20
> >=20
> > I have not tested it yet. But i think i should work, the code is mo=
stly
> > stolen from the udp.c file. Since the stack not depend on the len f=
ield
> > of the UDP header, it should not matter if UPD or UDP-Lite is used.
> >=20
>=20
> Hmm, but isnt your :
>=20
> udpcp_prot =3D udp_prot; /* in udpcp_init() */
>=20
> implies that all UDPCP sockets you are going to provide to user are o=
n
> top of UDP, not UDPLITE ?
>=20

Okay, i kick to udplite support away!

> Also, could you provide a link to UDPCP protocol specs ?
>=20

http://read.pudn.com/downloads76/doc/project/283718/OBSAI/OBSAI/RP1_V2.=
0.PDF

> Thanks
>=20
>=20
