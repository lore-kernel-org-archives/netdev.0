From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 02 Jan 2011 12:33:16 +0100
Message-ID: <1293967996.2535.76.camel@edumazet-laptop>
References: <1293918276-28773-1-git-send-email-stefani@seibold.net>
	 <1293920601.2535.64.camel@edumazet-laptop>
	 <1293967023.29525.16.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293967023.29525.16.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 02 janvier 2011 =C3=A0 12:17 +0100, Stefani Seibold a =C3=A9=
crit :
> Am Samstag, den 01.01.2011, 23:23 +0100 schrieb Eric Dumazet:

> > 3) I see UDPLITE references in your code. Are you sure UDPCP protoc=
ol
> > can really work on top of UDPLITE ? I think not, so please remove d=
ead
> > code.
> >=20
>=20
> I have not tested it yet. But i think i should work, the code is most=
ly
> stolen from the udp.c file. Since the stack not depend on the len fie=
ld
> of the UDP header, it should not matter if UPD or UDP-Lite is used.
>=20

Hmm, but isnt your :

udpcp_prot =3D udp_prot; /* in udpcp_init() */

implies that all UDPCP sockets you are going to provide to user are on
top of UDP, not UDPLITE ?

Also, could you provide a link to UDPCP protocol specs ?

Thanks
