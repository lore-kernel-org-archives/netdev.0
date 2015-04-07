From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage socket
Date: Tue, 07 Apr 2015 10:20:58 +0200
Message-ID: <5523936A.9010609@baanhofman.nl>
References: <20150406.124114.924455461962119301.davem@davemloft.net>	 <20150406.131700.185460014498109286.davem@davemloft.net>	 <CALx6S35bZ6t9d+cpHRXYS94N6rGuHhACMAt9Bj6UzCwBuomBSA@mail.gmail.com>	 <20150406.235118.65925113152002205.davem@davemloft.net>	 <CALx6S36f8SQQoNvzPyCNk4=0LbH4Od6ZtdDn0DCA2sZGZHMx2g@mail.gmail.com> <1428383028.25985.209.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="hUqGsQvqsuuAsV0AUI5OPrp2oT7pe78dN"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.baanhofman.nl ([92.222.219.102]:34446 "EHLO
	vps.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbbDGIVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 04:21:04 -0400
In-Reply-To: <1428383028.25985.209.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--hUqGsQvqsuuAsV0AUI5OPrp2oT7pe78dN
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 07/04/15 07:03, Eric Dumazet wrote:
> On Mon, 2015-04-06 at 21:45 -0700, Tom Herbert wrote:
>> On Mon, Apr 6, 2015 at 8:51 PM, David Miller <davem@davemloft.net> wro=
te:
>>> I don't see what is convoluted about using the correct socket for
>>> sending L3 protocol frames.  That's in fact how it's _supposed_ to
>>> work.  And consistently having a proper matching socket available
>>> makes it so that, long-term, we'll never have to deal with this issue=

>>> ever again.
>> I guess this is where I'm confused. We can send just about anything
>> over GRE also, but have never needed a transmit socket for that. Is
>> UDP encapsulation so different, or is GRE equally broken also? Also,
>> will we need to add the socket to FOU and GUE then?
> GRE encap is very low level (not L3), and no socket simply sends GRE
> packets as is.
FWIW, GRE encap is also broken for IPv6, it's layer 2, but only 8 bytes
can be used of the IPv6 address, because it uses sll_addr.

-- Wilco


--hUqGsQvqsuuAsV0AUI5OPrp2oT7pe78dN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCgAGBQJVI5NqAAoJENNgJ82k1pS9KEcP/3cXE09CExwlTrFwdPKdP3Hi
4Nsk7r8SxYyUG0QA8pFFQw5du+vSmhg7avJbwC6LZ20bVAGkI68uhrldu/KpAc3/
oTnurap9JHdwdgn9H1JfmVxVZl4jPUp1I0fLnxiTSsuPIqRB6HAIkL1YyDq4LPPo
h84EJi4hqXuw2t65Pm0aHJ4agl4vZ7b0jboMXv970aZFdksYfzQEOg+ZCyCoxAFl
mqbNH/xWcoU7ScWg/boqsspIcuMA3+5G4VwYBq4ep35vh04ai6gLiRUKUo5zlgow
wlmE2GFRYJtFSlpq/cP+4isOG1L071hwc47s5H4cON0RPCfLdfWTKCq9w0/gwgz6
bxYQh6UT7X3YCTGJnGxXmAC+yUdpwKpQgVoUWCbG5rAufEGo9YxK6sXT4oWX1STH
Q5xk/NvW6Yk2j0U4Hbl1DXDxc+ZUj4cI8EaaCvlA+eCEYmIdJbkzGdKv1VPwWfsF
qQXvxTT5boN9QydJgeoo+6tcPM9KHPA8XIS0Bvt/S/a4YaHR9uxLiq0HUwekCXOt
mY3qKUPUe3QVu3z8c4Az9iIiquOmGJxj3sIHcSNbRPgLvZGoVrxZEuNyDli7FCs6
A8RTnR4IEQD8FC7xqeX0nbYrjPoHtdOkbxX8/ZAva0XCwgPrUkLne+hSm+CizIkk
n94Ym27Q2sDhoWeZjv+K
=ll4m
-----END PGP SIGNATURE-----

--hUqGsQvqsuuAsV0AUI5OPrp2oT7pe78dN--
