From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast retransmit
Date: Tue, 13 Dec 2011 15:31:00 +0100
Message-ID: <1323786660.2744.1.camel@edumazet-laptop>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
	 <1322239016.5793.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <C2C333F1-98FD-41FB-9CFA-EDE9F363CABF@mpi-bpc.mpg.de>
	 <1323441811.2336.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <6DA1FA31-8983-4338-A1B8-5697A876E2B6@mpi-bpc.mpg.de>
	 <1323448264.5661.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <53E23320-FE3E-4B9C-95FA-132F75E89E83@mpi-bpc.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56097 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab1LMObG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 09:31:06 -0500
Received: by vbbfc26 with SMTP id fc26so4697213vbb.19
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 06:31:05 -0800 (PST)
In-Reply-To: <53E23320-FE3E-4B9C-95FA-132F75E89E83@mpi-bpc.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 d=C3=A9cembre 2011 =C3=A0 15:05 +0100, Esztermann, Ansgar a=
 =C3=A9crit :
> On Dec 9, 2011, at 17:31 , Eric Dumazet wrote:
>=20
> >>> It seems you have a lot of packet reorders.
> >>>=20
> >>> Are you using multipath or some channel bonding ?
> >>=20
> >> Not that I am aware of (i.e. not on our end). However, the connect=
ion
> >> will probably routed through a firewall. I will have to check if i=
t is
> >> configured to avoid reordering.
> >>=20
> >=20
> > Is it a linux based firewall ?
>=20
> No, it's Cisco.
>=20

OK

You could increase /proc/sys/net/ipv4/tcp_reordering from 3 to 16

(Not sure it will change anything, since its kinda dynamic for a tcp
session)
