From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 04/17] tcp: deferring in middle of queue makes
 very little sense
Date: Mon, 02 Mar 2009 03:01:22 -0800 (PST)
Message-ID: <20090302.030122.137983077.davem@davemloft.net>
References: <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46956
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754452AbZCBLBk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:01:40 -0500
In-Reply-To: <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:29 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> If skb can be sent right away, we certainly should do that
> if it's in the middle of the queue because it won't get
> more data into it.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.

I can't believe this check was missing :-)
