From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Bind fackets_out state to highest_sack more
 tightly
Date: Mon, 10 Dec 2007 15:55:06 -0800 (PST)
Message-ID: <20071210.155506.26256910.davem@davemloft.net>
References: <Pine.LNX.4.64.0712101426010.18529@kivilampi-30.cs.helsinki.fi>
	<20071210.043127.60066660.davem@davemloft.net>
	<Pine.LNX.4.64.0712101437080.3437@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38893
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751012AbXLJXzI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 18:55:08 -0500
In-Reply-To: <Pine.LNX.4.64.0712101437080.3437@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 10 Dec 2007 14:39:46 +0200 (EET)

> On Mon, 10 Dec 2007, David Miller wrote:
>=20
> > From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Mon, 10 Dec 2007 14:27:24 +0200 (EET)
> >=20
> > > Added checks will catch most of the errors if the current
> > > complex fack_count counting logic is flawed somewhere.
> > >=20
> > > Fackets_out should always be advancable if highest_sack is too
> > > because the fackets_out is nowadays accurate (and obviously it
> > > must be smaller than packets_out).
> > >=20
> > > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> >=20
> > Applied to net-2.6.25, thanks!
>=20
> Please get the fack_count fix as well from the mm1 thread before my=20
> mailbox gets filled with stacktraces :-) :
>   http://marc.info/?l=3Dlinux-netdev&m=3D119728952018975&w=3D2

Done, thanks!
