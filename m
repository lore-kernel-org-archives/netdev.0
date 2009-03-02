From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 05/17] tcp: Don't clear hints when
 tcp_fragmenting
Date: Mon, 02 Mar 2009 03:01:28 -0800 (PST)
Message-ID: <20090302.030128.231538664.davem@davemloft.net>
References: <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46959
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755802AbZCBLBr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:01:47 -0500
In-Reply-To: <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:30 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> 1) We didn't remove any skbs, so no need to handle stale refs.
>=20
> 2) scoreboard_skb_hint is trivial, no timestamps were changed
>    so no need to clear that one
>=20
> 3) lost_skb_hint needs tweaking similar to that of
>    tcp_sacktag_one().
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
