From: David Miller <davem@davemloft.net>
Subject: Re: Suspicious fackets_out handling
Date: Mon, 02 Jul 2007 22:07:50 -0700 (PDT)
Message-ID: <20070702.220750.108808313.davem@davemloft.net>
References: <Pine.LNX.4.64.0704231218440.28337@kivilampi-30.cs.helsinki.fi>
	<20070531.125929.77054675.davem@davemloft.net>
	<Pine.LNX.4.64.0706011417430.28601@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51043
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750712AbXGCFHa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 01:07:30 -0400
In-Reply-To: <Pine.LNX.4.64.0706011417430.28601@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 1 Jun 2007 15:17:00 +0300 (EEST)

> On Thu, 31 May 2007, David Miller wrote:
>=20
> > Is it possible to update fastpath_cnt_hint properly perhaps?
>=20
> I think that would be valid and even accurate as it can checks skb's
> seq against fastpath_skb_hint->seq. I'm in a hurry and will be a week
> out of reach of internet connectivity but here's quick attempt to dea=
l
> with this cleanly. Compile tested (be extra careful with this one, it=
's=20
> done i a hurry :-)), consider to net-2.6. Considering the marginality=
 of=20
> this issue, stable might really be an overkill for this one, only a
> remotely valid concern comes to my mind in this case: possibility
> of fackets_out > packet_out might not be dealt that cleanly everywher=
e=20
> (but I'm sure that you can come to a good decicion about it):
>=20
> [PATCH] [TCP]: SACK fastpath did override adjusted fackets_out
>=20
> Do same adjustment to SACK fastpath counters provided that
> they're valid.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Since the case is marginal and the patch does need some testing
I'm putting this into net-2.6.23 for now.
