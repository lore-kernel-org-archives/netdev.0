From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Fri, 4 Dec 2009 14:58:36 +0100
Message-ID: <20091204135836.GB17976@sd-11162.dedibox.fr>
References: <4B16BD58.3040802@tvk.rwth-aachen.de> <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <4B17A791.80808@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi> <4B17C6C3.1060000@tvk.rwth-aachen.de> <20091203202328.62d7551a@houba> <4B1820B8.7050500@tvk.rwth-aachen.de> <20091204093629.GA17976@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912041302460.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:57275 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbZLDN6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 08:58:32 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912041302460.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2009 at 01:14:46PM +0200, Ilpo J=E4rvinen wrote:
> On Fri, 4 Dec 2009, Frederic Leroy wrote:
>=20
> I noticed that we'll absolutely need that || !retrans_stamp thing as=20
> [...]=20
> But there may be other error handling related things here too. Can yo=
u try=20
> with the following once you can (probably can print quite much, once =
per=20
> arriving packet when in recovery):

I made 2 more trace .15 and .16 but ...=20
I applied your patch and forgot to add "|| !retrans_stamp" thing.

I can't test another kernel until this evening :(

--=20
=46r=E9d=E9ric Leroy
