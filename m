From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: provide more information on the tcp receive_queue
 bugs
Date: Fri, 13 Nov 2009 13:56:55 -0800 (PST)
Message-ID: <20091113.135655.212863096.davem@davemloft.net>
References: <alpine.DEB.2.00.0911091053200.13479@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, arjan@infradead.org,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35981
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754574AbZKMV4j convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 16:56:39 -0500
In-Reply-To: <alpine.DEB.2.00.0911091053200.13479@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 9 Nov 2009 11:19:18 +0200 (EET)

> The addition of rcv_nxt allows to discern whether the skb
> was out of place or tp->copied. Also catch fancy combination
> of flags if necessary (sadly we might miss the actual causer
> flags as it might have already returned).
>=20
> Btw, we perhaps would want to forward copied_seq in
> somewhere or otherwise we might have some nice loop with
> WARN stuff within but where to do that safely I don't
> know at this stage until more is known (but it is not
> made significantly worse by this patch).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-2.6, thanks a lot!
