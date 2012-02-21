From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.3-rc3+ Crash in __neigh_for_each_release
Date: Tue, 21 Feb 2012 20:15:56 +0100
Message-ID: <1329851756.18384.47.camel@edumazet-laptop>
References: <alpine.SOC.1.00.1202201359190.8004@math.ut.ee>
	 <1329851004.18384.45.camel@edumazet-laptop>
	 <20120221.140716.1396286389544946379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mroos@linux.ee, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61846 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755818Ab2BUTQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 14:16:01 -0500
Received: by wgbdt10 with SMTP id dt10so5989396wgb.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 11:16:00 -0800 (PST)
In-Reply-To: <20120221.140716.1396286389544946379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 14:07 -0500, David Miller a =C3=A9=
crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 21 Feb 2012 20:03:24 +0100
>=20
> > But I dont know enough this code to know if the following patch is =
the
> > way to fix this. (and __neigh_for_each_release() can also be delete=
d if
> > no users left in tree)
>=20
> I think instead of removing the code, we need to have it iterate over
> "arp_tbl" but only invoke the callback for devices which are of type
> ATM.

That makes sense...

Or invoke callback for all entries, and filter in callback non ATM ones=
=2E
