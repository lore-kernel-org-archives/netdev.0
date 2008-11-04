From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH]: drivers/net: Kill now superfluous ->last_rx stores.
Date: Tue, 04 Nov 2008 07:39:25 +0100
Message-ID: <490FEE1D.5090307@cosmosbay.com>
References: <20081103.211255.143270364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42941 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbYKDGjg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 01:39:36 -0500
In-Reply-To: <20081103.211255.143270364.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> Checking this in made me feel as if the weight of the
> world had been lifted off of my shoulders :-)

Oh great !

One thing we wont discuss anymore once in a while :)

>=20
> Commited to net-next-2.6
>=20
> drivers/net: Kill now superfluous ->last_rx stores.
>=20
> The generic packet receive code takes care of setting
> netdev->last_rx when necessary, for the sake of the
> bonding ARP monitor.
>=20
> Drivers need not do it any more.
>=20
> Some cases had to be skipped over because the drivers
> were making use of the ->last_rx value themselves.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>

