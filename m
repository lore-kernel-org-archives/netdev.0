From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Tue, 20 Dec 2011 08:18:43 +0100
Message-ID: <20111220071843.GL6348@secunet.com>
References: <20111216122147.GJ6348@secunet.com>
 <20111219.161053.148816799233666803.davem@davemloft.net>
 <4EF030D5.6040603@iki.fi>
 <20111220.020355.942849877817117461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36955 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765Ab1LTHSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Dec 2011 02:18:45 -0500
Content-Disposition: inline
In-Reply-To: <20111220.020355.942849877817117461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2011 at 02:03:55AM -0500, David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Tue, 20 Dec 2011 08:53:09 +0200
>=20
> > Or maybe I missed the place where that updated would happen?
>=20
> It should happen on every routing cache lookup hit just like we
> validate the peer for redirect information.

The problem is that we need to do a route cache lookup to
validate the peer informations. This does not happen if
somebody adds a new route. I tried already to add a pmtu specific
generation id and it appears to not solve the problem. We would
still need to overwrite the cached value if we add a route with mtu.
