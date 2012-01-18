From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] ipv6: dst_allfrag() not taken into account by TCP
Date: Wed, 18 Jan 2012 15:59:06 +0100
Message-ID: <1326898746.2316.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F15D417.4050005@fud.no> <1326831948.2606.2.camel@edumazet-laptop>
	 <00f1ef555b452980aae95eb3028072f8@localhost>
	 <1326895569.2316.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <9903c7bcb83314b495e7378dae23e703@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50291 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757821Ab2ARO7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 09:59:11 -0500
Received: by bkas6 with SMTP id s6so2844638bka.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 06:59:09 -0800 (PST)
In-Reply-To: <9903c7bcb83314b495e7378dae23e703@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 15:43 +0100, Tore Anderson a =C3=A9c=
rit :

> Another way of solving it and avoiding the Fragmentation headers
> altogether would be to allow the "route MTU" to drop below 1280 as a
> result of Path MTU Discovery. I opened an enchancement bug report
> requesting this:
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D42599

Please dont open bugzilla entries for this kind of stuff, since there i=
s
no bug in this case.

netdev is more appropriate to discuss future improvements.
