From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problems with /proc/net/tcp6  - possible bug - ipv6
Date: Sat, 22 Jan 2011 22:40:44 +0100
Message-ID: <1295732444.2651.68.camel@edumazet-laptop>
References: <702550.61465.qm@web63902.mail.re1.yahoo.com>
	 <1295686781.2609.37.camel@edumazet-laptop>
	 <1295709344.2651.55.camel@edumazet-laptop>
	 <115440.16148.qm@web63902.mail.re1.yahoo.com>
	 <1295731235.2651.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: PK <runningdoglackey@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44590 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab1AVVkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jan 2011 16:40:51 -0500
In-Reply-To: <1295731235.2651.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 22 janvier 2011 =C3=A0 22:20 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le samedi 22 janvier 2011 =C3=A0 11:42 -0800, PK a =C3=A9crit :
> > Eric Dumazet wrote:
> > >=20
> > > I had some incidents, after hours of testing...
> > >
> > > After following patch, I could not reproduce it.
> >=20
> >=20
> > Looks like that patch solved the /proc/net/tcp6 problem.  The causa=
l commit was=20
> > the one you identified... confirmed with bisect.
> >=20
> > These warnings show up when I run the script (or I presume any tcp6=
 connection=20
> > flooder) with /proc/sys/net/tcp/ipv4/tcp_tw_recycle enabled.  There=
's textual=20
> > corruption of the traces a lot of the time.  Here's a sample trace =
that doesn't=20
> > appear to be corrupt.  All the warnings I've seen are from route.c:=
209, and I=20
> > don't see how that would cause memory corruption.
>=20
> Thats a different isse, already reported, under investigation.
>=20
> David did some changes recently
>=20
> http://comments.gmane.org/gmane.linux.network/179874
>=20
>=20
>=20

In my testings, I even have crashes in cleanup_once() if I
enable /proc/sys/net/ipv4/tcp_tw_recycle=20



