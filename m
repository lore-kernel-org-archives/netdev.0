From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Thu, 11 Aug 2011 20:05:25 -0700
Message-ID: <1313118339.2029.1.camel@jtkirshe-mobl>
References: <20110812120248.a23ecc95e9c1111da3a8ef30@canb.auug.org.au>
	 <1313116296.2057.30.camel@jtkirshe-mobl>
	 <20110811.195150.1070520107072994432.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-M2yiEpagJgF9JDRMOBtn"
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23706 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751975Ab1HLDFk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 23:05:40 -0400
In-Reply-To: <20110811.195150.1070520107072994432.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-M2yiEpagJgF9JDRMOBtn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-08-11 at 19:51 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 11 Aug 2011 19:31:35 -0700
>=20
> > I am curious, can you compile the Sun GEM support driver?  and if so,
> > does the Spider Net driver compile?
>=20
> I'm pretty sure you cannot reference object targets outside of
> the current directory and expect it to work.
>=20
> You can only reference things in the current directory (objects,
> directories to traverse down into, etc.) as targets
>=20
> So when there is a common piece of infrastructure shared by
> two drivers, you're really going to have to cope with them
> at the same time.

I am working on a patch now to fix this.

Stephen - if you could compile test it, I would greatly appreciate.

--=-M2yiEpagJgF9JDRMOBtn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJORJh1AAoJECTsCADr/EWUdLgH/1cBztEYeR8BHUyHidsWeHH5
NIcnihy20vrclE9KV4hWPpQ6alOfrYCuNpC9OqpeqGppZSpIsb0xMWrbMIjSu9n3
jjh0VgZIWQg7n2kdV6s4WtoPxlZv80roeL9lmYSOoP1FIS/18r4GZW05mHFv51uK
0T4mNFoLohqm5xT4onnzMIiA4uAEOi0eiQiSkQ9SE0angzSLla3J9huXjx6vFZEX
21vxNk2THiekPl7jwbfQ3OB8qV13zH6gBCH7PvzbBTG5nIxKHs58HJBzG1sR56CM
e+RJdQa2VmBmqAX26sNV5LjhcXLCHT9KlcQu2Ncjy9Kso2zCIbfEMCbUvMEncrE=
=7usg
-----END PGP SIGNATURE-----

--=-M2yiEpagJgF9JDRMOBtn--

