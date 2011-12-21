From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Wed, 21 Dec 2011 19:00:01 +0100
Message-ID: <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF200BB.7000209@bootc.net>
	 <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF2117F.6000803@bootc.net>
	 <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Chris Boot <bootc@bootc.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 18:36 +0100, Eric Dumazet a =C3=
=A9crit :

> Good point, thats a different problem then, since 3.1 is not supposed=
 to
> have this bug.
>=20
> It seems rt->rt6i_peer points to invalid memory in your crash.
>=20
> (RBX=3D00000000000001f4)
>=20
> 8b 83 a4 00 00 00       mov    0xa4(%rbx),%eax    p->refcnt
> 1f4+a4 -> CR2=3D0000000000000298
>=20

It would help if you can confirm latest linux tree can reproduce the
bug.

Thanks !
