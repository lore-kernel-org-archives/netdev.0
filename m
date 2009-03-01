From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 01/17] tcp: fix retrans_out leaks
Date: Sun, 01 Mar 2009 00:22:11 -0800 (PST)
Message-ID: <20090301.002211.165202295.davem@davemloft.net>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751045AbZCAIW3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 03:22:29 -0500
In-Reply-To: <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:26 +0200

> There's conflicting assumptions in shifting, the caller assumes
> that dupsack results in S'ed skbs (or a part of it) for sure but
> never gave a hint to tcp_sacktag_one when dsack is actually in
> use. Thus DSACK retrans_out -=3D pcount was not taken and the
> counter became out of sync. Remove obstacle from that information
> flow to get DSACKs accounted in tcp_sacktag_one as expected.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>

Applied, thanks.
