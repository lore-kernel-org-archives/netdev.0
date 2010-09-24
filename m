From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Fri, 24 Sep 2010 18:05:52 +0200
Message-ID: <1285344352.2503.321.camel@edumazet-laptop>
References: <20100922162209.GA10281@babylon>
	 <20100922.203442.233700254.davem@davemloft.net>
	 <20100923144708.GA8037@babylon> <1285254302.2509.47.camel@edumazet-laptop>
	 <4C9CBCFC.6080300@gmail.com> <1285342083.2503.252.camel@edumazet-laptop>
	 <4C9CC608.7010401@astaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <ulrich.weber@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ulrich Weber <uweber@astaro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36930 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab0IXQF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 12:05:59 -0400
Received: by fxm3 with SMTP id 3so811775fxm.19
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 09:05:58 -0700 (PDT)
In-Reply-To: <4C9CC608.7010401@astaro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 17:38 +0200, Ulrich Weber a =C3=A9=
crit :
> Yes, as I wrote before my Cable ISP is flooding me with
> ARP requests from 10.0.0.0/8, which get a route
> via the primary PPP link.
>=20
> I know thats not a common setup but why do that
> kind of routes have to be cached ? :)
>=20
>=20
> steps to reproduce:
> server:
>  ip route add 1.0.0.0/8 dev dummy0
>=20
> client:
>  ip route add 1.0.0.0/8 dev eth0
>  nmap --min-rate 500 -sP 1.0.0.0/8
>=20

Great, you use nmap and fill 'client' neighbour cache.

Now, back to the _real_ problem, please ?

<quote>

Background: At home I have two Internet connections, DSL and Cable.
DSL is the primary uplink while Cable is the secondary.
My Cable ISP is flooding me with ARP request from 10.0.0.0/8,
which creates routes via the primary uplink.
There are thousands of cached routes and after some time
I get "Neighbour table overflow" messages.

</quote>

You receive an ARP request on device eth1,
this creates a route on eth0 ?

Could you send your routing/address setup ?

ip addr
ip ro



