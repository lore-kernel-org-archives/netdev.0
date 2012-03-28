From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH] f_phonet: fix skb truesize underestimation
Date: Wed, 28 Mar 2012 11:55:36 +0300
Message-ID: <20120328085535.GF18156@arwen.pp.htv.fi>
References: <1332853442.3248.15.camel@edumazet-laptop>
 <20120327.225109.752822925052179338.davem@davemloft.net>
Reply-To: balbi@ti.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CXFpZVxO6m2Ol4tQ"
Cc: eric.dumazet@gmail.com, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org, balbi@ti.com,
	remi.denis-courmont@nokia.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:58572 "EHLO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757369Ab2C1I4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 04:56:07 -0400
Received: by mail-bk0-f54.google.com with SMTP id jc3so1230547bkc.27
        for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 01:56:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120327.225109.752822925052179338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--CXFpZVxO6m2Ol4tQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 27, 2012 at 10:51:09PM -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 27 Mar 2012 06:04:02 -0700
>=20
> > Now skb_add_rx_frag() has a truesize parameter, we can fix f_phonet to
> > properly account truesize of each fragment : a full page.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied.

did you apply both patches ?

--=20
balbi

--CXFpZVxO6m2Ol4tQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPctIHAAoJEIaOsuA1yqREu/MP/i1M97FpQAeQypYpvIai/On0
oVHM3y9hd69xehI9oogCerGL/Er5AU5i72am+PAr0JGGB+KO4vS3UVQbUwCYPJPy
wC0TxjUjQevdvM5mscNUHm4ECkAXXkAN3A8kXrsiKepm3YkXb6lric7kMXcIzGSX
+74DUy0d3yIY6PcWW/kl5nOcm15MjU1KnJgwsj5T1/5wYM3+38seqGi46TfykRyv
WhzQ282MLIP89uUgXtVm0fRYJggXDjHsZ9IXOevo/HzfG3L/muifPq0XY/QZRKYK
Oc1m0OZ6qbcYQwDQWfu9UHxFKwFzbKBbepQ0MO7TNnmjwwlhXA9xvMHvE3b8aWX+
NyvIS4LL6TIb4E0R3lE76Dd5HyDy0Re3ZuV5pt8t86gp9BzqVZoP2+pjPqmNUuFB
PQdB0bjN2qBcj3l9pwofVVMTE9BFtl5AtSNg7rxDwtHN3Uo4OqzoapwjInSCSGlp
lja8tNgYKPiWw35QAq/k8mQdCKeY/5roFqE3WpdvL23/oYbA/HS+HFdpGQYvntmO
AGywUejEBKtmF9vOZpstTLYtxc/nGJAiEWmuC6PdBJ8ffIAh+SN7wenHCmr0UWZA
eQfC98ggY5mIjAVSRO6yeSXa6Fox4Ow1z1/97WIIkNV1IhSiQo0R8lKM6zJ9SeQ2
E2YxKJT1Rh+I9RMPO6jZ
=RJYm
-----END PGP SIGNATURE-----

--CXFpZVxO6m2Ol4tQ--
