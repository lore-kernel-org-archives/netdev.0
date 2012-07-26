From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 19:02:37 +0200
Message-ID: <1343322157.2626.11740.camel@edumazet-glaptop>
References: <20120720.142502.1144557295933737451.davem@davemloft.net>
	 <20120722.173951.1794347789063177131.davem@davemloft.net>
	 <1343027752.2626.10175.camel@edumazet-glaptop> <500D8FEE.7050802@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57734 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab2GZRCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 13:02:44 -0400
Received: by bkwj10 with SMTP id j10so1409773bkw.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 10:02:42 -0700 (PDT)
In-Reply-To: <500D8FEE.7050802@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-23 at 19:54 +0200, Pawe=C5=82 Staszewski wrote:

> I make some real life tests with 10Gbit traffic and make some rdos.
> With kernel 3.4.5 when I reach 6M routing cache entries - traffic is =
not=20
> forwarded - on my hardware with 64G RAM
>=20
> With kernel - 3.5.0-rc7-next-20120720 + David M. patches - route cach=
e=20
> removal + fix
> Traffic is forwarder all the time at speed 8.2Mpps RX from traffic=20
> generator and 8.2Mpps TX to the sink
>=20
> Also I see performance improvement.
>=20
> With kernel 3.4.5 I can reach maximum od 7.5Mpps with my hardware
> And with kernel 3.5.0-rc7-next-20120720 i can reach 8.2Mpps - forward=
ing=20
> UDP performance - can be more - but my TX pktgen that use 6 cores can=
't=20
> do more.
>=20
> Really thanks for this :)

In real life, with TCP traffic, make sure you
set /proc/sys/net/ipv4/ip_early_demux to 0=20
