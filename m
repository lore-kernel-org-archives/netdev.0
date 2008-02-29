From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] [XFRM]: Speed up xfrm_policy and xfrm_state walking
Date: Thu, 28 Feb 2008 21:31:48 -0800 (PST)
Message-ID: <20080228.213148.12076357.davem@davemloft.net>
References: <47A3337C.1090004@iki.fi>
	<20080212.225908.92858029.davem@davemloft.net>
	<47B5D87E.3030208@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36494
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751417AbYB2Fbt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 00:31:49 -0500
In-Reply-To: <47B5D87E.3030208@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Fri, 15 Feb 2008 20:22:54 +0200

> Change xfrm_policy and xfrm_state walking algorithm from O(n^2) to O(=
n).
> This is achieved adding the entries to one more list which is used
> solely for walking the entries.
>=20
> This also fixes some races where the dump can have duplicate or missi=
ng
> entries when the SPD/SADB is modified during an ongoing dump.
>=20
> Dumping SADB with 20000 entries using "time ip xfrm state" the sys
> time dropped from 1.012s to 0.080s.
>=20
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Applied, although this will make add/delete slightly slower.

Could you do that AF_KEY dumping patch you talked about?  I change my
mind, we can do it.

THanks.
