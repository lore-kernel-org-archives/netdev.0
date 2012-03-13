From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Tue, 13 Mar 2012 00:25:59 -0700 (PDT)
Message-ID: <20120313.002559.340117447102423900.davem@davemloft.net>
References: <20120312.225435.1585479447873313061.davem@davemloft.net>
	<CAHo-Ooyi_NOZeT978EjUaPSYBMco9FmQh8uNpCLr-6owfYyMTQ@mail.gmail.com>
	<CAHo-OoyWH9v+D7yJp3sAKnmUEp_DiTeDhmgPme2dGoqWGa2qjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759355Ab2CMH0B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 03:26:01 -0400
In-Reply-To: <CAHo-OoyWH9v+D7yJp3sAKnmUEp_DiTeDhmgPme2dGoqWGa2qjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Tue, 13 Mar 2012 00:23:27 -0700

> I was actually leaning towards going with ffs()-1, since
>=20
> it's excellent on x86-64
> good on x86_cmov
> decent on x86
> good on armv5+
>=20
> and I'm guessing it'll be good or better on any modern platform

Cycle count it with the pure integer operation variant, I bet it's
within a cycle or two, and at that point we're just splitting hairs
for an ugly-as-sin ifdef.
