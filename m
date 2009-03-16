From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] tcp: cache result of earlier divides when
 mss-aligning things
Date: Sun, 15 Mar 2009 20:11:15 -0700 (PDT)
Message-ID: <20090315.201115.23510598.davem@davemloft.net>
References: <12370756752721-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20090315083642.GA31423@ioremap.net>
	<Pine.LNX.4.64.0903151041350.23360@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zbr@ioremap.net, netdev@vger.kernel.org, mingo@elte.hu
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39273
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751147AbZCPDL2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 23:11:28 -0400
In-Reply-To: <Pine.LNX.4.64.0903151041350.23360@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sun, 15 Mar 2009 10:45:16 +0200 (EET)

> [PATCHv2] tcp: cache result of earlier divides when mss-aligning thin=
gs
>=20
> The results is very unlikely change every so often so we
> hardly need to divide again after doing that once for a
> connection. Yet, if divide still becomes necessary we
> detect that and do the right thing and again settle for
> non-divide state. Takes the u16 space which was previously
> taken by the plain xmit_size_goal.
>=20
> This should take care part of the tso vs non-tso difference
> we found earlier.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
