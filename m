From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bad TCP timestamps on non-PC platforms
Date: Fri, 07 Jan 2011 03:11:21 +0100
Message-ID: <1294366281.2704.36.camel@edumazet-laptop>
References: <117536.54377.qm@web37607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Alex Dubov <oakad@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63324 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756876Ab1AGCL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 21:11:26 -0500
Received: by wyb28 with SMTP id 28so16992713wyb.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 18:11:24 -0800 (PST)
In-Reply-To: <117536.54377.qm@web37607.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 janvier 2011 =C3=A0 17:55 -0800, Alex Dubov a =C3=A9crit :
> Sorry for the awful synopsis of my problem. I never cease to amaze my=
self
> at how bad those usually turn up. :-)
>=20
> What I really meant to write is:
>=20
> I have a dev board running 2.6.37-rc7. Normal kernel config, nothing =
fancy.
> Remote machines are just usual linux boxes in constant operation (I t=
ried
> several of those).
>=20
> UDP/DHCP works correctly all the time, so ethernet side is probably o=
k.
>=20
> When tcp_timestamps are enabled, SYN packets from dev board just get
> ignored by the remote side. I see them arrive in wireshark, but nothi=
ng
> else happens.
>=20
> When I disable tcp_timestamps on the dev board everything works.
>=20
> The problem is reproducible every single time.
>=20
> The only difference is the "Options" block of the SYN packets.
> If timestamps are not really to blame, then it probably window scale
> parameters. That's what I see on a usual dropped packet:
>=20
> Options: (20 bytes)
>         Maximum segment size: 1460 bytes
>         SACK permitted
>         Timestamps: TSval 4294893842, TSecr 0
>         NOP
>         Window scale: 5 (multiply by 32)
>=20
>=20
>=20
>      =20


You dont give new informations ;)

I asked if you could give information on the other side : The bug is to
drop this legal packet.

uname -a
sysctl -a | grep tcp


