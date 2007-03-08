From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: TCP RB tree core v2.
Date: Wed, 07 Mar 2007 20:22:46 -0800 (PST)
Message-ID: <20070307.202246.74747538.davem@davemloft.net>
References: <20070307.123743.74748673.davem@davemloft.net>
	<Pine.LNX.4.64.0703080616480.27671@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53597
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751707AbXCHEWs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 23:22:48 -0500
In-Reply-To: <Pine.LNX.4.64.0703080616480.27671@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 8 Mar 2007 06:21:03 +0200 (EET)

> On Wed, 7 Mar 2007, David Miller wrote:
>=20
> > I checked the TCP write queue abstraction patch into the net-2.6.22
> > GIT tree at:
> >=20
> > 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.22.git
>=20
> While tried to apply your patch below, I noticed it's already there. =
It=20
> turns out that ebbe72e602c1e825c8ec97349095bdd286c0ff24 seems to=20
> be a mess, it includes also rbtree stuff you are giving below.

I noticed this just an hour ago too.

I'm rebasing the tree and checking it in properly this time
with a bug fix or two :)

Stephen Hemminger noticed that it crashes with TSO, which still
isn't fixed, and I'm trying to figure out that bug right now.
