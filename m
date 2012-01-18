From: Tore Anderson <tore@fud.no>
Subject: Re: [RFC] ipv6: =?UTF-8?Q?dst=5Fallfrag=28=29=20not=20taken=20into=20acco?=
 =?UTF-8?Q?unt=20by=20TCP?=
Date: Wed, 18 Jan 2012 16:14:40 +0100
Message-ID: <184325098dff696295968e09accafa9d@localhost>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F15D417.4050005@fud.no> <1326831948.2606.2.camel@edumazet-laptop> <00f1ef555b452980aae95eb3028072f8@localhost> <1326895569.2316.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <9903c7bcb83314b495e7378dae23e703@localhost> <1326898746.2316.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from greed.fud.no ([87.238.35.20]:36512 "EHLO greed.fud.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757652Ab2ARPOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 10:14:42 -0500
In-Reply-To: <1326898746.2316.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet

> Le mercredi 18 janvier 2012 =C3=A0 15:43 +0100, Tore Anderson a =C3=A9=
crit :
>=20
>> Another way of solving it and avoiding the Fragmentation headers
>> altogether would be to allow the "route MTU" to drop below 1280 as a
>> result of Path MTU Discovery. I opened an enchancement bug report
>> requesting this:
>>=20
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D42599
>=20
> Please dont open bugzilla entries for this kind of stuff, since there=
 is
> no bug in this case.

Okay...but then what is the =C2=ABenhanchement=C2=BB severity's intende=
d use?

> netdev is more appropriate to discuss future improvements.

No problem. Bottom line, I'd like a "min_pmtu" IPv6 sysctl or something
similar that would allow me to configure it so that the kernel would=20
accept an arbitrary low PMTU being received in an ICMPv6 PTB. That=20
would prevent having to deal with the Fragmentation headers completely.

Best regards,
--=20
Tore Anderson
