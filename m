From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: oops during unregister_netdevice interface enslaved to
 bond - regression
Date: Tue, 10 May 2011 10:59:19 +0200
Message-ID: <1305017959.2614.13.camel@edumazet-laptop>
References: <OF0F4919C3.B9CFCAE8-ONC125788C.002D5EB1-C125788C.002D83B7@de.ibm.com>
	 <1305017672.2614.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Frank Blaschka <Frank.Blaschka@de.ibm.com>
To: Einar EL Lueck <ELELUECK@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46973 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932131Ab1EJI7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 04:59:24 -0400
Received: by wwa36 with SMTP id 36so6634240wwa.1
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 01:59:23 -0700 (PDT)
In-Reply-To: <1305017672.2614.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 10 mai 2011 =C3=A0 10:54 +0200, Eric Dumazet a =C3=A9crit :

> I am currently working on this stuff [adding even more batching and
> probably bugs as well ], so instead of revert I'll try to find a way =
to
> fix this.
>=20
> If you already have a script to reproduce the bug on virtual devices =
on
> x86 (not on s390 machines I dont have ;) ), I'll appreciate having a
> copy of it.
>=20
> Thanks for the reminder.

BTW make sure latest linux-2.6 still exhibits the problem, we fixed som=
e
things after original Octavian commit

List of commits :

commit ceaaec98ad99859ac90ac6863ad0a6cd075d8e0e
net: deinit automatic LIST_HEAD

commit f87e6f47933e3ebeced9bb12615e830a72cedce4=20
net: dont leave active on stack LIST_HEAD=20



