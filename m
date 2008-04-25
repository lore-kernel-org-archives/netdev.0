From: David Miller <davem@davemloft.net>
Subject: Re: XTP for 2.6.25
Date: Fri, 25 Apr 2008 13:12:55 -0700 (PDT)
Message-ID: <20080425.131255.95495287.davem@davemloft.net>
References: <18b669d80804250151h516788cdqc7931a7ab5a195de@mail.gmail.com>
	<20080425.015508.254917794.davem@davemloft.net>
	<Pine.LNX.4.64.0804251558550.1888@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shigeonx@gmail.com, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45439
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762636AbYDYUMz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 16:12:55 -0400
In-Reply-To: <Pine.LNX.4.64.0804251558550.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 25 Apr 2008 16:05:51 +0300 (EEST)

> On Fri, 25 Apr 2008, David Miller wrote:
>=20
> > From: "Shigeo N" <shigeonx@gmail.com>
> > Date: Fri, 25 Apr 2008 17:51:49 +0900
> >=20
> > > One host(sender) is 2.6.25, but the other(receiver) is 2.6.18.
> > > I will evaluate again after I upgrade it to 2.6.25.
> >=20
> > The bug fix isn't in 2.6.25 either.
>=20
> Sure it is, or git is lying:
>=20
> $ git-describe dd9e0dda66ba38a2ddd1405ac279894260dc5c36
> v2.6.25-rc8-1190-gdd9e0dd

I just submitted the TCP reorder patch for 2.6.25-stable, it applied
on top of a tree for which I did:

	git checkout -b linux25 v2.6.25

so something is up :-)
