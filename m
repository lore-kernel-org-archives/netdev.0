From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] flow: better memory management
Date: Mon, 13 Sep 2010 07:51:51 +0200
Message-ID: <1284357111.5560.2533.camel@edumazet-laptop>
References: <1284138025.24675.100.camel@edumazet-laptop>
	 <87tyluk35t.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50679 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab0IMFwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 01:52:04 -0400
Received: by wwb13 with SMTP id 13so3436286wwb.1
        for <netdev@vger.kernel.org>; Sun, 12 Sep 2010 22:52:02 -0700 (PDT)
In-Reply-To: <87tyluk35t.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 septembre 2010 =C3=A0 00:28 +0200, Andi Kleen a =C3=A9crit =
:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>=20
> > Allocate hash tables for every online cpus, not every possible ones=
=2E
>=20
> There are some setups that boot most of the CPUs after boot.
> On those this heuristic would be very wrong.
>=20

Why ?

I dont get your argument Andi.

I coded following obvious thing :

At boot : Allocate tables for online cpus

When bringing up a cpu online : allocate table for this "new" cpu.

What could be wrong with this ?

On my machine, this works well and save 16 "tables", because I have 16
online cpus, while they are 32 possible cpus (Its a lie, since I have
two quad core cpus, and a total of 16 threads)





