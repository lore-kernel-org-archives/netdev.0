From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: No networking since git3
Date: Sat, 19 Mar 2011 16:33:41 +0100
Message-ID: <1300548821.2831.28.camel@edumazet-laptop>
References: <4D84A46B.1000407@example.com>
	 <AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com>
	 <1300547930.2831.27.camel@edumazet-laptop>
	 <201103191631.07952.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Anca Emanuel <anca.emanuel@gmail.com>, piotr@hosowicz.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60537 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754238Ab1CSPds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 11:33:48 -0400
In-Reply-To: <201103191631.07952.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 19 mars 2011 =C3=A0 16:31 +0100, Oliver Neukum a =C3=A9crit :
> Am Samstag, 19. M=C3=A4rz 2011, 16:18:50 schrieb Eric Dumazet:
>=20
> > Problem comes from commit 54405cde762408b00a445466a40da4f7f33a8479
> > (r8169: support control of advertising.)
> >=20
> > Reverting it brings back NIC for me
>=20
> Odd. It worked for me. Are you testing on a gigabit switch? Could you=
 send
> me dmesg? Does it work if you use ethtool to advertise a lower speed?
>=20
> 	Regards
> 		Oliver

I found the bug, I am sending a patch in two minutes.


