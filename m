From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 11:39:35 +0200
Message-ID: <20080731093935.GB23814@xi.wantstofly.org>
References: <20080731004123.GB22826@xi.wantstofly.org> <E1KONuu-00017h-00@gondolin.me.apana.org.au> <20080731023652.GA23814@xi.wantstofly.org> <20080731030339.GA4327@gondor.apana.org.au> <Pine.LNX.4.64.0807310942130.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, akarkare@marvell.com,
	nico@cam.org
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:55164 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166AbYGaJjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 05:39:37 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0807310942130.4551@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 09:55:57AM +0300, Ilpo J=E4rvinen wrote:

> > > The maximum that splice will allow -- PIPE_BUFFERS * PAGE_SIZE.
> > >=20
> > > I.e. the writes should be large enough.
> >=20
> > Have you looked at the packet dump?
>=20
> ...That would be helpful indeed.
>=20
> > Maybe it was being constrained by the receiver/congestion windows.
>=20
> The thing that came into my mind is that the link might still be fast=
=20
> enough to make the transfer application limited, can you try setting=20
> /proc/sys/net/ipv4/tcp_slow_start_after_idle to zero and retest.

=46rom a couple of quick tests, that doesn't seem to change anything
as far as transfer speed or CPU usage are concerned.
