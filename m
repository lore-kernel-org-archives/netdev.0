From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 16:41:41 +0100
Message-ID: <201103191641.41718.oliver@neukum.org>
References: <4D84A46B.1000407@example.com> <1300548821.2831.28.camel@edumazet-laptop> <1300549151.2831.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anca Emanuel <anca.emanuel@gmail.com>, piotr@hosowicz.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300549151.2831.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Samstag, 19. M=C3=A4rz 2011, 16:39:11 schrieben Sie:
> Le samedi 19 mars 2011 =C3=A0 16:33 +0100, Eric Dumazet a =C3=A9crit =
:
> > Le samedi 19 mars 2011 =C3=A0 16:31 +0100, Oliver Neukum a =C3=A9cr=
it :
> > > Am Samstag, 19. M=C3=A4rz 2011, 16:18:50 schrieb Eric Dumazet:
> > >=20
> > > > Problem comes from commit 54405cde762408b00a445466a40da4f7f33a8=
479
> > > > (r8169: support control of advertising.)
> > > >=20
> > > > Reverting it brings back NIC for me
> > >=20
> > > Odd. It worked for me. Are you testing on a gigabit switch? Could=
 you send
> > > me dmesg? Does it work if you use ethtool to advertise a lower sp=
eed?
> > >=20
> > > 	Regards
> > > 		Oliver
> >=20
> > I found the bug, I am sending a patch in two minutes.
> >=20
>=20
> Here it is
>=20
> [PATCH] r8169: fix a bug in rtl8169_init_phy()
>=20
> commit 54405cde7624 (r8169: support control of advertising.)
> introduced a bug in rtl8169_init_phy()

Thank you. I feel like banging my head against something.

	Regards
		Oliver
