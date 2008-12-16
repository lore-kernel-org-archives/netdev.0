From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipmr: merge common code
Date: Tue, 16 Dec 2008 01:15:29 -0800 (PST)
Message-ID: <20081216.011529.199285599.davem@davemloft.net>
References: <Pine.LNX.4.64.0812132151320.4160@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60104
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751547AbYLPJP2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 04:15:28 -0500
In-Reply-To: <Pine.LNX.4.64.0812132151320.4160@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 13 Dec 2008 21:59:34 +0200 (EET)

> Also removes redundant skb->len < x check which can't
> be true once pskb_may_pull(skb, x) succeeded.
 ...
> It seems that pimlen arg could be left out as well and
> eq-sizedness of structs trapped with BUILD_BUG_ON but
> I don't think that's more than a cosmetic flaw since there
> aren't that many args anyway.
>=20
> Compile tested.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Also applied, thanks Ilpo.
