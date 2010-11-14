From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: a Great Idea - include Kademlia networking protocol in
 kernel -- REVISITED
Date: Sun, 14 Nov 2010 10:39:04 +0100
Message-ID: <1289727544.2743.72.camel@edumazet-laptop>
References: <AANLkTi=VgBQ5rwkjZeo2zsRx1dSBy+4PBXeLLPQ4LRES@mail.gmail.com>
	 <AANLkTinWUmQ91cCULC8ZXFLwSKz6SNt3BpszrBEhbgcu@mail.gmail.com>
	 <1289724643.2743.58.camel@edumazet-laptop>
	 <AANLkTimkPpWob8ANySeWBvDE+Pq2wy4SQWJOSYzbS7QG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Guerin <stephen@sfcomplex.org>
To: Marcos <stalkingtime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54359 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754279Ab0KNJjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 04:39:11 -0500
Received: by wwb29 with SMTP id 29so335729wwb.1
        for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 01:39:10 -0800 (PST)
In-Reply-To: <AANLkTimkPpWob8ANySeWBvDE+Pq2wy4SQWJOSYzbS7QG@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 14 novembre 2010 =C3=A0 02:14 -0700, Marcos a =C3=A9crit :
> > I have no idea why and how kademlia would be added to "linux kernel=
"
> >
> > Its a protocol based on UDP, and probably already done on userland.
> >
> > What am I missing ?
>=20
> The idea is to tightly couple it to the operating system to create a
> sort of "super operating system" that is seamless to the application
> layers above.  Just like memory stores are tightly integrated as to b=
e
> unnoticeable....
>=20

But we dont want a "super operating system". We want a good one.

Memory stores done in userland are as fast as memory stores done in
kernel.

Once you need to access files, perform complex searches, timers,
logging, and all the stuff, you really want to do it from userland, in
high level language that many programmers master, or get something that
is too complex/buggy.



