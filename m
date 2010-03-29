From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Minimizing TCP latency
Date: Mon, 29 Mar 2010 07:34:51 +0200
Message-ID: <1269840891.2256.28.camel@edumazet-laptop>
References: <7c93bf1e1003281829h3ddba989w198df86ac9f2d27c@mail.gmail.com>
	 <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hoyt <benhoyt@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:36353 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671Ab0C2Fey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 01:34:54 -0400
Received: by bwz1 with SMTP id 1so3270122bwz.21
        for <netdev@vger.kernel.org>; Sun, 28 Mar 2010 22:34:53 -0700 (PDT)
In-Reply-To: <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 mars 2010 =C3=A0 16:24 +1300, Ben Hoyt a =C3=A9crit :
> > I'm happy to receive some pointers via this list [...]
>=20
> Sorry, I should also have posted more about what I've done in terms o=
f
> reducing latency so far:
>=20
> * We've already got TCP_NODELAY activated.

One machine sends messages, and messages are not aknowledged by other
part ? Is it one way communication ?

>=20
> * We've also turned off interrupt coalescing on the network card (for
> example, see http://www.29west.com/docs/THPM/latency-interrupt-coales=
cing.html).
>=20
> * We've modified our process's CPU affinity so it runs on a core by
> itself, reducing interrupt-handling latency slightly further.
>=20
> * Our code is written in C, and we've tried to keep it as close to th=
e
> kernel's socket calls as possible.
>=20



So we're currently looking further into ways to reduce latency, which
> currently looks like it'll mean digging deeper into the kernel's
> networking options and innards.
>=20
> FYI, we're using RHE release 4 and kernel version 2.6.9 on x86_64 mac=
hines.

What are the targets ?  (time constraints)

Mono threaded application handling one tcp flow ?

Are you handling a very light load on few flows, or many flows ?=20

Are machines all in the same LAN ?


