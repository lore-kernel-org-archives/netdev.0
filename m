From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 02/17] tcp: don't backtrack to sacked skbs
Date: Mon, 02 Mar 2009 03:01:03 -0800 (PST)
Message-ID: <20090302.030103.89533524.davem@davemloft.net>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46950
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753724AbZCBLBV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:01:21 -0500
In-Reply-To: <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:27 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Backtracking to sacked skbs is a horrible performance killer
> since the hint cannot be advanced successfully past them...
> ...And it's totally unnecessary too.
>=20
> In theory this is 2.6.27..28 regression but I doubt anybody
> can make .28 to have worse performance because of other TCP
> improvements.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
