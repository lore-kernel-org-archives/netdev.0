From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next v2 11/12] i40e/i40evf: carefully fill tx ring
Date: Sun, 09 Mar 2014 19:52:11 +0000
Message-ID: <1394394731.15968.27.camel@deadeye.wl.decadent.org.uk>
References: <1394161164-26645-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1394161164-26645-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RI+iylB4c8JLCSJGnfJa"
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51339 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751327AbaCITwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 15:52:20 -0400
In-Reply-To: <1394161164-26645-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RI+iylB4c8JLCSJGnfJa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-06 at 18:59 -0800, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>=20
> We need to make sure that we stay away from the cache line
> where the DD bit (done) may be getting written back for
> the transmit ring since the hardware may be writing the
> whole cache line for a partial update.
[...]

This seems like quite a serious bug.  Is it not important enough for net
& stable updates? =20

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-RI+iylB4c8JLCSJGnfJa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxzGa+e/yOyVhhEJAQpslA//Var6X5Bjv0LW6smmvU3WczB6pi/xzR78
2+RrhOnPbcAGQor5FjLGp4ygMLhvo8f5AiIFCjlMSqHRwF497wQL7RxHMfPdVxIR
RO83wrwK5l12+0zE4oqHYAy+HhzCoplPEzfzk9upNrIcTLziXsGw+A8EHH4JEwVm
96ydOxPGlyJg3ia+gXIj/2Jg2zcpXNFFICPrVbCKSOT71B+xKssV7LNDSoqLFQOt
/UZHcWFwcIcrefmmeKP0fzr2RQSJ+iE4/wAVk01nJM7nPpxx4Z1mROG4mHzHH6t5
8kjC5n2JvKJ9oz2ADzC14OrUfsgItKA86JtKky2yKI30kxPIH+3ml+yR4+Yjz/C5
maqK4172piKQdsuyOTQ2iEe5YoOJY+hfzednglf9f4/37289C/Vm2z6Z+PrGXXHl
5tlzj9FwTmqFEPCTnvbfkBx8YEvi+c7Bo1oHwpz6xWkZJIf1+i1761tRigSW9kxM
Aq0bY9jo8RBSXYiYDr7ClyDm/TYpxgZWsnR9XIHg6cS1g9DG5CBhH592fqBBtL9+
k798AIwhampc0qK6wLU/aFPN80Zal1/1Q43fhM9ZzH7RIA4zyO62nJ5DUcbgMmUs
ty0l+gbG+hIw6LDsTi7JY+0Vh1bXNlu/6RwV7CPPmrEY1mApZj7PKpfuhhgz02v7
yJpUjxJ+ZsQ=
=snqz
-----END PGP SIGNATURE-----

--=-RI+iylB4c8JLCSJGnfJa--
