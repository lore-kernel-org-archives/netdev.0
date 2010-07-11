From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Sun, 11 Jul 2010 10:36:59 +0200
Message-ID: <1278837419.2538.131.camel@edumazet-laptop>
References: <1278695580.2696.55.camel@edumazet-laptop>
	 <AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	 <1278742649.2538.17.camel@edumazet-laptop>
	 <20100710.123011.260095467.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: felipewd@gmail.com, kaber@trash.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100710.123011.260095467.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 10 juillet 2010 =C3=A0 12:30 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 10 Jul 2010 08:17:29 +0200
>=20
> > Strange thing with your crash report is CR2 value, with unexpected =
value
> > of 000000000b388000 while RAX value is dce8dce85d415d41
> >=20
> > Faulting instruction is :
> >=20
> > 48 83 b8 b0 00 00 00 00   cmpq   $0x0,0xb0(%rax)
> >=20
> > So I would have expected CR2 being RAX+0xb0, but its not.
>=20
> It could be corruption from elsewhere.  Those last four hex
> digits (0x5d415d41) are "]A]A" in ascii, but that could just
> be coincidence.
>=20

x86 being litle endian, string is "A]A]" followed by another "XYXY"
pattern (non ASCII chars : 0xE8, 0xDC, 0xE8, 0xDC, "=C3=A8=C3=9C=C3=A8=C3=
=9C" in ISO8859)
