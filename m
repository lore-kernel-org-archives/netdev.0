From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bad TCP timestamps on non-PC platforms
Date: Mon, 10 Jan 2011 08:07:56 +0100
Message-ID: <1294643276.2709.877.camel@edumazet-laptop>
References: <373539.88491.qm@web37603.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Alex Dubov <oakad@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43048 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730Ab1AJHIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 02:08:13 -0500
Received: by wwa36 with SMTP id 36so368944wwa.1
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 23:08:12 -0800 (PST)
In-Reply-To: <373539.88491.qm@web37603.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 09 janvier 2011 =C3=A0 22:33 -0800, Alex Dubov a =C3=A9crit=
 :
> > > Any ideas where this particular problem may
> > originate?
> >=20
> > Is there a bug in checksum offload in the driver?
> > Does the hardware correctly handle checksum of packets that
> > are
> > unaligned or whose length is an odd number of bytes?
> >=20
> > If the hardware can't do checksum correctly, the driver
> > should either
> > disable checksum offload or in worst case copy the packet
> > to a new
> > buffer that is in a known safe place.
>=20
> I managed to work around the issue by clearing the NETIF_F_IP_CSUM
> feature flag of the gianfar network driver, so it appears the bug is
> indeed somewhere there.
>=20

Its incredible how TCP timestamps can be "usual suspects" ;)



