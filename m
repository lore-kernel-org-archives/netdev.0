From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 2.6.37 : oops in cleanup_once
Date: Wed, 02 Feb 2011 12:24:47 +0100
Message-ID: <1296645887.20445.11.camel@edumazet-laptop>
References: <4D491B8D.1000107@univ-nantes.fr>
	 <1296643972.20445.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296643972.20445.9.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 11:52 +0100, Eric Dumazet a =C3=
=A9crit :
> Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 09:53 +0100, Yann Dupont a =C3=
=A9crit :
> > Hello.
> > We recently upgraded one machine with vanilla 2.6.37, and experienc=
ed 2=20
> > kernel oops since. Each oops is after ~1 week of uptime.
> > The last oops was last night but we didn't had any trace.

oops, 2.6.37 "only"

> Yes this is a known problem.
>=20
> Please try commit 3408404a4c2a4eead9d73b0bbbfe3f225b65f492
> (inetpeer: Use correct AVL tree base pointer in inet_getpeer())
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D3408404a4c2a4eead9d73b0bbbfe3f225b65f492
>=20
> I believe David will send it to stable team shortly, if not already
> done :)

Please ignore, this patch was for linux-2.6 tree, 2.6.37 was not
affected by the problem.

So its another problem... Is there anything particular you do on this
machine ?
