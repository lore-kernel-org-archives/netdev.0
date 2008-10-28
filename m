From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
	addresses
Date: Tue, 28 Oct 2008 09:06:26 +0100
Message-ID: <1225181186.3796.71.camel@johannes.berg>
References: <1225137542.5396.10.camel@brick>
	 <20081027.154736.178482850.davem@davemloft.net>
	 <1225149254.6339.4.camel@brick>
	 <20081027.165556.30975206.davem@davemloft.net>
	 <1225152339.5526.1.camel@brick>  <1225153359.5269.112.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Zvqdjih7hO5WSTMLeT8m"
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	David Miller <davem@davemloft.net>, anders@anduras.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:51211 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbYJ1IGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 04:06:34 -0400
In-Reply-To: <1225153359.5269.112.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Zvqdjih7hO5WSTMLeT8m
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-10-27 at 17:22 -0700, Joe Perches wrote:
> On Mon, 2008-10-27 at 17:05 -0700, Harvey Harrison wrote:
> > On Mon, 2008-10-27 at 16:55 -0700, David Miller wrote:
> > > I'm ok with the '#' modifier but remind me again what's wrong with
> > > using plain %p4 and %p6?
> > Nothing at all, just wanted to know what color bikeshed you wanted.
> > I'll go with %p4 %p6.
>=20
> Just an FYI for v6 addresses:
>=20
> There are a few uses of ipv6 address as "%08X%08X%08X%08X"=20
> Pavel Emelyanov tried to isolate them with a suggested patch:
>=20
> http://www.mail-archive.com/netdev@vger.kernel.org/msg51655.html
>=20
> These addresses are not shown in network order, but are
> printed backwards in host order. Oops.  Apparently it's
> too late to fix them.

So that code we don't touch here at all.

johannes

--=-Zvqdjih7hO5WSTMLeT8m
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBsf7AAoJEKVg1VMiehFYk04P/A8HmZYZq1pqvu2IA3l0Ww2i
bhGjJzO4SZSs75wHT+exPXmKUmWSbeueasxOyFS9PosIo5iRYjq2v7qgzJXH2mf9
DzWaoAn3WCxW2iolhFLZGVrGRUJhAqGhakhskM2gLHTiIeKSV6MtCQCNjLVayynQ
uYeuttx456/UwMeUDSgMypAOxOkKKXYHT4OXQ8xgz0I0wuU+UM3xLkdkcyy7aHZG
6KfwuX/s47Z9Q3BFBw46JLS26evcStMI9UYIFXcXLSanDcFGsJddikEnQABQ0GAp
IiVjPt+jpwLpOKKL4EMGuE3gomSAP6QDj9GzHgaOix0Xppf8AH7l1NtI231+9EC6
tvBuXaFYfDhR3KjfcSzzmti2+JGYy00Slb0VWXqX43l34o2PHr/SEGQDkDAiISwe
eMacSPMF9oOJCjJej81q2BHKcXsqEtDowT8fR1VV/RvxFGr98iXyQB7WWOQsk93a
wc5mutba4c4m4AQZHdwAzk82zooBCGgSoZY7I4KAqnnFTf23WYBR8tdTqcclMVgO
G0anZz2GZiBXA0YuRVptF3pk2OseiHwZbosfXPLq8L4vql/9w2l30pKgkZmw8CVx
Gmg5qhGjU7ZZpvFIxxxLEfv/HtF8djEJe66/6xcIhqiJ8MmXkLMfNBSyLK/XNjGy
zSUuPReRkPJFswf7phlD
=msGc
-----END PGP SIGNATURE-----

--=-Zvqdjih7hO5WSTMLeT8m--

