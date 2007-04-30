From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] [TCP]: Catch skb with S+L bugs earlier
Date: Mon, 30 Apr 2007 00:28:37 -0700 (PDT)
Message-ID: <20070430.002837.27783394.davem@davemloft.net>
References: <Pine.LNX.4.64.0703281650150.27182@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52040
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423092AbXD3H2k convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 03:28:40 -0400
In-Reply-To: <Pine.LNX.4.64.0703281650150.27182@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 28 Mar 2007 17:02:47 +0300 (EEST)

> SACKED_ACKED and LOST are mutually exclusive, thus this
> condition is bug with SACK (IMHO). NewReno, however, could get
> enough duplicate ACKs which increment sacked_out, so it makes
> sense to do this kind of limitting for non-SACK TCP but not for
> SACK-enabled one. Perhaps the author had that in mind but did
> the logic accidently wrong way around?
>=20
> Eventually these bugs trigger traps in the tcp_clean_rtx_queue
> but it's much more informative to do this here (excludes some
> other possible bugs).
>=20
> Maybe this BUG_TRAP is too expensive to be included everywhere
> in the TCP code. Should there be some #if to surround it?
>=20
> Compile tested. Sadly enough I don't have time for couple of
> weeks to test this as it would require some setuping, and besides,
> my test machines are occupied currently to other work, but this=20
> might also be net-2.6 (or even stable) material if it really
> works (feel free to cut this paragraph or part of it if you
> decide to include this :-)).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I've applied this, thanks for your patience.

I will see if it makes my workstation explode :-)
