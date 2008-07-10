From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Detecting TCP loss on the receiving side?
Date: Thu, 10 Jul 2008 14:14:18 -0700
Message-ID: <48767BAA.3090704@hp.com>
References: <4876668C.8040108@limebrokerage.com> <48766CF0.1020101@hp.com> <48766EC2.2090000@limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Dan_No=E9?= <dnoe@limebrokerage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:2343 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525AbYGJVOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 17:14:23 -0400
In-Reply-To: <48766EC2.2090000@limebrokerage.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan No=E9 wrote:
> Rick Jones wrote:
>=20
>> If this is just for troubleshooting, why not just take a tcpdump tra=
ce?
>=20
>=20
> We're pushing a lot of data.. several Mbps pretty much all day long..=
=20
> and the (suspected) loss occurs sporadically.  Ideally we'd like to b=
e=20
> able to easily correlate it with latency seen in our app.

If your app can already log a timestamped "high latency" warning, then=20
it would simply be a matter of a big disc and comparing timestamps in=20
the tcpdump trace :)

Also, it appears that for what you want, you only need to capture up=20
through the TCP header, so while it may be many Mbit/s on the wire, it=20
will be fewer Mbit/s in the trace.

rick jones
