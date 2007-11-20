From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 (2nd try)] [TCP] MTUprobe: fix potential
 sk_send_head corruption
Date: Mon, 19 Nov 2007 23:24:49 -0800 (PST)
Message-ID: <20071119.232449.13837118.davem@davemloft.net>
References: <Pine.LNX.4.64.0711191559060.24866@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0711191610590.24866@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753292AbXKTHYu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 02:24:50 -0500
In-Reply-To: <Pine.LNX.4.64.0711191610590.24866@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 19 Nov 2007 16:15:54 +0200 (EET)

> [PATCH] [TCP] MTUprobe: fix potential sk_send_head corruption
>=20
> When the abstraction functions got added, conversion here was
> made incorrectly. As a result, the skb may end up pointing
> to skb which got included to the probe skb and then was freed.
> For it to trigger, however, skb_transmit must fail sending as
> well.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks for catching this Ilpo.
