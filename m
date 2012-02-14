From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] 3c59x: shorten timer period for slave devices
Date: Tue, 14 Feb 2012 22:02:56 +0100
Message-ID: <1329253376.2555.14.camel@edumazet-laptop>
References: <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <201202141350.57657.jdelvare@suse.de> <20120214133418.GJ32155@v3-1054>
	 <20120214.144335.558771219791311889.davem@davemloft.net>
	 <1329251229.2555.10.camel@edumazet-laptop>
	 <1329252670.3054.85.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	klassert@mathematik.tu-chemnitz.de, jdelvare@suse.de,
	fubar@us.ibm.com, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:55304 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757006Ab2BNVDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 16:03:00 -0500
Received: by werb13 with SMTP id b13so213978wer.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 13:02:59 -0800 (PST)
In-Reply-To: <1329252670.3054.85.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 f=C3=A9vrier 2012 =C3=A0 14:51 -0600, Dan Williams a =C3=A9=
crit :
> On Tue, 2012-02-14 at 21:27 +0100, Eric Dumazet wrote:
> > Jean Delvare reported bonding on top of 3c59x adapters was not dete=
cting
> > network cable removal fast enough.
> >=20
> > 3c59x indeed uses a 60 seconds timer to check link status if carrie=
r is
> > on, and 5 seconds if carrier is off.
> >=20
> > This patch reduces timer period to 5 seconds if device is a bonding
> > slave.
>=20
> Maybe for posterity give some rationale as to why we feel we can redu=
ce
> it to 5 seconds for slaves instead of reducing the timer period in
> general?  If you weren't party to this discussion that won't be appar=
ent
> from the commit log.

Apparently, Andrew Morton considered firing a timer every 5 seconds was
too expensive. I am not sure we want to state this (probably old fact)
in the changelog. Anyway are these slow NICS still used in 2011 ? ;)
