From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpa10x: free sk_buff with kfree_skb
Date: Wed, 29 Oct 2008 22:07:56 -0700 (PDT)
Message-ID: <20081029.220756.228643919.davem@davemloft.net>
References: <20081026.232626.97216182.davem@davemloft.net>
	<Pine.LNX.4.64.0810271821340.7072@wrl-59.cs.helsinki.fi>
	<77F72F81-CC03-4032-A648-01B4F5D4CECC@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47104
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751364AbYJ3FIV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 01:08:21 -0400
In-Reply-To: <77F72F81-CC03-4032-A648-01B4F5D4CECC@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 30 Oct 2008 05:09:34 +0100

> Hi Ilpo,
>=20
> >> 2) Couple places trying to pass sk_buff to kfree() instead of
> >>   kfree_skb().  Fixed by Sergio Luis
> >
> > I tried with coccinelle and found one more of these, though my
> > other attempts with it haven't been all that successful...
> >
> >
> > --
> > [PATCH] bpa10x: free sk_buff with kfree_skb
> >
> > Inspired by Sergio Luis' similar patches, I finally found
> > a case which is trivial enough that spatch won't choke
> > on it.
> >
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> good catch.
>=20
> Acked-by: Marcel Holtmann <marcel@holtmann.org>
>=20
> Dave, feel free to take this directly and apply it to your trees.

Thanks, I will.
