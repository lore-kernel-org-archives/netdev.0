From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] [TCP]: Catch skb with S+L bugs earlier
Date: Mon, 30 Apr 2007 00:57:37 -0700 (PDT)
Message-ID: <20070430.005737.24335918.davem@davemloft.net>
References: <20070430.002837.27783394.davem@davemloft.net>
	<Pine.LNX.4.64.0704301037080.29336@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0704301045100.29336@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54516
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423143AbXD3H5k convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 03:57:40 -0400
In-Reply-To: <Pine.LNX.4.64.0704301045100.29336@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 30 Apr 2007 10:49:21 +0300 (EEST)

> On Mon, 30 Apr 2007, Ilpo J=E4rvinen wrote:
>=20
> > On Mon, 30 Apr 2007, David Miller wrote:
> >=20
> > > From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> > > Date: Wed, 28 Mar 2007 17:02:47 +0300 (EEST)
> > >=20
> > > > SACKED_ACKED and LOST are mutually exclusive, thus this
> > > > condition is bug with SACK (IMHO). NewReno, however, could get
>=20
> [...snip...]
>=20
> > > I've applied this, thanks for your patience.
>=20
> ...heh... I was getting a bit unsure whether you still had them...
>=20
> > I think I sent an updated version later (hopefully I reach you befo=
re=20
> > you push these out :-)), which made the BUG_ON unconditional (I use=
d it=20
> > instead of BUG_TRAP as it seems to be generic machinery for handlin=
g=20
> > these).
>=20
> Here:
>   http://marc.info/?l=3Dlinux-netdev&m=3D117648826715609&w=3D2

Thanks, I'll swap in that version of the patch.
