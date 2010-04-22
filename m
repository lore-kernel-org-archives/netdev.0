From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Wed, 21 Apr 2010 22:56:25 -0700 (PDT)
Message-ID: <20100421.225625.177238009.davem@davemloft.net>
References: <1271456302.16881.4559.camel@edumazet-laptop>
	<20100418.024601.85853662.davem@davemloft.net>
	<1271830116.7895.1316.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44729
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752692Ab0DVF4U convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 01:56:20 -0400
In-Reply-To: <1271830116.7895.1316.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Apr 2010 08:08:36 +0200

> Le dimanche 18 avril 2010 =E0 02:46 -0700, David Miller a =E9crit :
>=20
>> Looks good, applied, thanks Eric.
>=20
> Hmm, looking at the GSO stuff, I believe we should not call
> skb_orphan_try() on gso skbs ?

Right, I've applied this, thanks.

What we should probably do instead is call and NULL out the
DEV_GSO_CB() destructor.  Right?
