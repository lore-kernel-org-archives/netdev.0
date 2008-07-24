From: =?ISO-8859-1?Q?Dan_No=E9?= <dpn@isomerica.net>
Subject: Re: TUN/TAP hacking
Date: Wed, 23 Jul 2008 22:25:28 -0400
Message-ID: <4887E818.4020305@isomerica.net>
References: <20080723235514.GA8992@zenon.in.qult.net>
Reply-To: dpn@isomerica.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ignacy Gawedzki <lkml@qult.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colobus.isomerica.net ([216.93.242.10]:43091 "EHLO
	colobus.isomerica.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbYGXCga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 22:36:30 -0400
In-Reply-To: <20080723235514.GA8992@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ignacy Gawedzki wrote:
> I need some advice from network stack experts, so I hope this is the =
right
> place to ask.

The Linux kernel networking folks hang out at netdev
(netdev@vger.kernel.org).  I've CC'd them...

> I thought I'd be able to use the TAP interfaces to create some sort o=
f a
> network emulator.  For a start I just "bridged" two tap interfaces, m=
uch in
> the same way as the example of br_select.c from http://vtun.sf.net , =
assigned
> both interfaces different IPv4 addresses (both with a /32 prefix), se=
t them up
> and tried to transmit a UDP packet from one address to the other thro=
ugh the
> bridge.  Both logs from my bridge program and tcpdump tell me that th=
e packets
> are flowing as expected, but somehow the destination process doesn't =
get the
> packets (despite all correct bind, etc).
>=20
> Is it simply that the stack inconditionally drops any packet with the=
 same
> source (IP and/or MAC) address as some local interface?
>=20
> As ARP resolution seems not to work either (I had to put permanent en=
tries in
> the neighbor table), I suppose this is the case indeed.
>=20
> Could anyone confirm that? (please CC me, I've not subscribed)
>=20
> Thanks,
>=20
> Ignacy
>=20


--=20
                    /--------------- - -  -  -   -   -
                    |  Dan No=E9
                    |  http://isomerica.net/~dpn/
