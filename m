From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Wed, 16 Jan 2008 23:59:23 -0800 (PST)
Message-ID: <20080116.235923.208347316.davem@davemloft.net>
References: <478EF542.1010702@iki.fi>
	<20080116.231654.74131878.davem@davemloft.net>
	<478F05E7.6070503@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750865AbYAQH7Y convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 02:59:24 -0500
In-Reply-To: <478F05E7.6070503@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Thu, 17 Jan 2008 09:38:15 +0200

> David Miller wrote:
> > From: Timo_Ter=E4s <timo.teras@iki.fi>
> > Date: Thu, 17 Jan 2008 08:27:14 +0200
> >=20
> >> I don't know about netlink. But pfkey works in *BSD too and it is =
RFC'd.
> >> So I'd say pfkey might be a bit more portable. Though netlink is d=
efinitely
> >> more robust and extensive.
> >=20
> > The RFCs say absolutely nothing about policy interfaces for AF_KEY,
> > everybody rolls their own in slightly incompatible ways.
> >=20
> > It is therefore anything but standardized.
>=20
> Yes, there's non-standardized extensions.

You can't implement a keying daemon without policy support, and policy
support is where the "non-standardized extensions" live.

Doing anything other than "life support" bug fixes for AF_KEY is
inappropriate.
