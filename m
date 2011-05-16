From: David Miller <davem@davemloft.net>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 19:06:15 -0400 (EDT)
Message-ID: <20110516.190615.2121423692228640268.davem@davemloft.net>
References: <20110516121857.GA4495@gondor.apana.org.au>
	<BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
	<20110516224658.GA11157@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirqus@gmail.com, mst@redhat.com, shanwei@cn.fujitsu.com,
	mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755766Ab1EPXGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 19:06:46 -0400
In-Reply-To: <20110516224658.GA11157@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Tue, 17 May 2011 08:46:58 +1000

> On Mon, May 16, 2011 at 02:24:19PM +0200, Micha=A9=A9 Miros=A9=A9aw w=
rote:
>>
>> In this case - no. Those messages inform that driver supports more
>> feature combinations than network core and the feature set is reduce=
d
>> because of that.
>=20
> The driver should never even claim to support SG/TSO/UFO if it
> does not support checksum.  That is the point of the warning.

Well the check has to exist somewhere.

Currently userspace can configure tun/tap into whatever set
of offloads it likes.

We're warning when the user asks for something that needs to be
corrected.  So the only thing you can suggest is to duplicate these
changes in the tun/tap driver.

But if we do that, and error on bad combinations instead of fixing
them up, we know from this discussion that existing virtualization
setups and tools are going to stop working.
