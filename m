From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: fack_counts more fixes (the previous ones were
 incomplete)
Date: Tue, 11 Dec 2007 04:15:07 -0800 (PST)
Message-ID: <20071211.041507.261395652.davem@davemloft.net>
References: <Pine.LNX.4.64.0712111339340.22872@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, reuben-linuxkernel@reub.net,
	akpm@linux-foundation.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52283
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752119AbXLKMPI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 07:15:08 -0500
In-Reply-To: <Pine.LNX.4.64.0712111339340.22872@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 11 Dec 2007 13:43:24 +0200 (EET)

> [PATCH] [TCP]: fack_counts more fixes (the previous ones were incompl=
ete)
>=20
> 1) Prev NULL check should also dereference
>=20
> 2) The loop reorganization did make things only slightly better,
>    just changing the same not-updated problem to occur in
>    another scenario. And I also noticed that in worst case it
>    would be an infinite loop (could do that also before the
>    change), but it required losses in the same window when TCP
>    runs out new data. Now check really against the list heads
>    rather than a valid skb which should still be processed.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
