From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: release skb->dst in sock_queue_rcv_skb()
Date: Wed, 26 Nov 2008 01:08:47 -0800 (PST)
Message-ID: <20081126.010847.98625035.davem@davemloft.net>
References: <492C919E.3050108@cosmosbay.com>
	<20081125.180404.157859705.davem@davemloft.net>
	<492CFD32.7020109@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751824AbYKZJIs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 04:08:48 -0500
In-Reply-To: <492CFD32.7020109@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 26 Nov 2008 08:39:30 +0100

> David Miller a =E9crit :
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Wed, 26 Nov 2008 01:00:30 +0100
> >=20
> > Can you do a quick check?
> >=20
>=20
> Sure I can do a check :)
>=20
> No impact at all on tbench, unless this bench can run in UDP mode :)

Durrr, of course!

Patch applied, thanks Eric.
