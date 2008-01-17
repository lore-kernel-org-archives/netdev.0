From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 02:06:16 -0800 (PST)
Message-ID: <20080117.020616.136852595.davem@davemloft.net>
References: <478F2205.80403@iki.fi>
	<20080117.014458.16733544.davem@davemloft.net>
	<478F276D.8080407@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53741
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754213AbYAQKGQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 05:06:16 -0500
In-Reply-To: <478F276D.8080407@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Thu, 17 Jan 2008 12:01:17 +0200

> David Miller wrote:
> > This is an inherent aspect of AF_KEY (and what it was
> > derived from, BSD routing sockets).
>=20
> Yes, this is the way BSD does it.
> =20
> > It has to provide dumps atomically, and if there is no
> > space there is no way to provide those entries which
> > would require more rcvbuf space.
>=20
> RFC does not say it has to be atomic.

Every application out there in the universe expects BSD socket
semantics, and therefore atomic dumps.  You cannot "fix" things
without breaking applications.
