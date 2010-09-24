From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Fri, 24 Sep 2010 17:28:03 +0200
Message-ID: <1285342083.2503.252.camel@edumazet-laptop>
References: <20100922162209.GA10281@babylon>
	 <20100922.203442.233700254.davem@davemloft.net>
	 <20100923144708.GA8037@babylon> <1285254302.2509.47.camel@edumazet-laptop>
	 <4C9CBCFC.6080300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <uweber@astaro.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ulrich Weber <ulrich.weber@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64602 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab0IXP2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 11:28:09 -0400
Received: by fxm3 with SMTP id 3so779688fxm.19
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 08:28:08 -0700 (PDT)
In-Reply-To: <4C9CBCFC.6080300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 17:00 +0200, Ulrich Weber a =C3=A9=
crit :
> Hi Eric,
>=20
> please find the output in the attached text file.
>=20
> Neighbor garbage collection wont't work because all
> neighbor records are bound to cached routes.
>=20
> Forced route garbaged collections returns without freeing
> any routes, probably because the route threshold is quite high
> with 65536 compared to the small neighbor threshold of 1024,
> resulting in a fixed amount of 1024 cached routes...
>=20
> Instead of running the garbage collection we could flush the route
> cache completely if the neighbor cache overflows.
> But why do we have to cache that routes in first place ?
> See the previous patch which skips caching for that kind of routes.

What are the packets you receive ? A flood of ARP answers ?

a "tcpdump -X" of a few packets would help to understand.



