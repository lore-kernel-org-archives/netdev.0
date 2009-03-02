From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/17] tcp: fix corner case issue in
 segmentation during rexmitting
Date: Mon, 02 Mar 2009 03:01:35 -0800 (PST)
Message-ID: <20090302.030135.108275627.davem@davemloft.net>
References: <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46962
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756902AbZCBLBx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:01:53 -0500
In-Reply-To: <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:31 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> If cur_mss grew very recently so that the previously G/TSOed skb
> now fits well into a single segment it would get send up in
> parts unless we calculate # of segments again. This corner-case
> could happen eg. after mtu probe completes or less than
> previously sack blocks are required for the opposite direction.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
