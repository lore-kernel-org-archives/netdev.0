From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: extend ECN sysctl to allow server-side
 only ECN
Date: Mon, 04 May 2009 11:07:53 -0700 (PDT)
Message-ID: <20090504.110753.39855338.davem@davemloft.net>
References: <Pine.LNX.4.64.0905041542100.10088@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53801
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754591AbZEDSH6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 14:07:58 -0400
In-Reply-To: <Pine.LNX.4.64.0905041542100.10088@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 4 May 2009 18:12:26 +0300 (EEST)

> This should be very safe compared with full enabled, so I see
> no reason why it shouldn't be done right away. As ECN can only
> be negotiated if the SYN sending party is also supporting it,
> somebody in the loop probably knows what he/she is doing. If
> SYN does not ask for ECN, the server side SYN-ACK is identical
> to what it is without ECN. Thus it's quite safe.
>=20
> The chosen value is safe w.r.t to existing configs which
> choose to currently set manually either 0 or 1 but
> silently upgrades those who have not explicitly requested
> ECN off.
>=20
> Whether to just enable both sides comes up time to time but
> unless that gets done now we can at least make the servers
> aware of ECN already. As there are some known problems to occur
> if ECN is enabled, it's currently questionable whether there's
> any real gain from enabling clients as servers mostly won't
> support it anyway (so we'd hit just the negative sides). After
> enabling the servers and getting that deployed, the client end
> enable really has some potential gain too.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Seems reasonable, applied, thanks!
