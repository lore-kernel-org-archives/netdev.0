From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Wed, 19 Dec 2007 18:07:24 +0100
Message-ID: <47694FCC.1020507@cosmosbay.com>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>	 <Pine.LNX.4.64.0712181704380.4422@fbirervta.pbzchgretzou.qr>	 <83a51e120712180845k6cadf67bn5dd66fb2d3ac72d4@mail.gmail.com>	 <Pine.LNX.4.64.0712181818360.4422@fbirervta.pbzchgretzou.qr>	 <83a51e120712181009pf954f43mcb63ea4dab638458@mail.gmail.com>	 <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr>	 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>	 <4768123A.7040603@cosmosbay.com>	 <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>	 <47682F8C.20205@cosmosbay.com> <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@computergmbh.de>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Nichols <jamesnichols3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39746 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438AbXLSRHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 12:07:33 -0500
In-Reply-To: <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Nichols a =E9crit :
>> So you see outgoing SYN packets, but no SYN replies coming from the =
remote
>> peer ?  (you mention ACKS, but the first packet received from the re=
mote
>>  peer should be a SYN+ACK),
>=20
> Right, I meant to say SYN+ACK.  I don't see them coming back.

So... Really unlikely a linux problem, but ...

>=20
>=20
>> When the problem comes, instead of restarting the application, pleas=
e take a
>> tcpdump of say 10.000 packets.
>> Then turn off tcp_sack and take a 2nd tcpdump sample, and make both =
samples
>> available to us.
>=20
> I can take these captures and take a look at the results.
> Unfortunately, I don't think I'll be able to make the captures
> available to the general public.

I dont understand, why dont you change IPs to mask them with 192.168.X.=
Y, or=20
just ME, and peer1, peer2, peer...

>=20
>=20
>=20
>> If turning off tcp_sack makes the problem go away, why dont you turn=
 it off
>> all the time ?
>=20
> Unfortunately, I think that will be the answer if I can't get any hel=
p
> fixing this problem in the kernel.  It's a bummer, because many of th=
e
> remote hosts my application communicates with are on wireless links,
> so there may be performance implications to turning SACK off.
>=20

Random ideas :

1) Is your server behind a NET router or something ?
2) Are you sure you are not using connection tracking, and hit a limit =
on it ?


