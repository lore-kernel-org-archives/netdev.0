From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 2.6.37 : oops in cleanup_once
Date: Wed, 02 Feb 2011 16:08:56 +0100
Message-ID: <1296659336.20445.22.camel@edumazet-laptop>
References: <4D491B8D.1000107@univ-nantes.fr>
	 <1296643972.20445.9.camel@edumazet-laptop>
	 <1296645887.20445.11.camel@edumazet-laptop>
	 <4D495765.4090806@univ-nantes.fr>
	 <1296658407.20445.19.camel@edumazet-laptop>
	 <4D49726C.6020103@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D49726C.6020103@univ-nantes.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 16:04 +0100, Yann Dupont a =C3=A9=
crit :
> >
> Ok, will do it at 18:30 CET (to minimize impact)
> It the suspected bug SLUB related ?
>=20

no : It can be a corruption from another part of kernel.

> The 2.6.34.2 kernel previously used on that server used SLAB.
>=20
>=20
> 2 questions :
> -How can I be sure slub_nomerge is active ? Boot message ?


# ls -l /sys/kernel/slab/

If you have symlinks : merge is on (default)

If you dont have symlinks : nomerge is in action

> -Is there a very severe impact on performance ?
>=20

not at all

> Regards,
>=20
