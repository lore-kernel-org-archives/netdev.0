From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 02/14] i40e: Allow disabling of DCB via debugfs
Date: Thu, 05 Jun 2014 01:05:53 -0700
Message-ID: <1401955553.19767.186.camel@jtkirshe-mobl>
References: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1401954567-13557-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20140605.005632.2052466271313574330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-62guamxOA8jp6QR59ujw"
Cc: neerav.parikh@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25530 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbaFEIFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 04:05:55 -0400
In-Reply-To: <20140605.005632.2052466271313574330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-62guamxOA8jp6QR59ujw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-06-05 at 00:56 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu,  5 Jun 2014 00:49:15 -0700
>=20
> > From: Neerav Parikh <neerav.parikh@intel.com>
> >=20
> > Diagnostic and traffic generator tests fail when DCB is enabled.
> > This is due to the fact that when DCB is enabled the Tx packets
> > from the adapter are VLAN tagged and these tests are not expecting
> > an extra tag in the packets.
> >=20
> > So, allow disabling of the DCB flag via debugfs so that these tests
> > can proceed.
> >=20
> > New debugfs commands
> > "dcb off" -- Disable DCB tagging; only works when in single TC mode
> > "dcb on" -- Re-enable DCB tagging
> >=20
> > Change-ID: I14cc894e1cbf8a3b8ecfba4a3886f9861e7678ed
> > Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Please define a portable, generic, interface for this that other
> drivers can make use of.
>=20
> And in the future, generally speaking, please stop plopping every
> diagnostic knob you come up with into debugfs by default.
>=20
> Thank you.

Sorry about that Dave, I should have gone with my gut feeling and
dropped this patch to begin with.  I even debated over it before sending
the series out.  I am just going to drop the patch from the series since
it will take Neerav time to define the generic interface.


--=-62guamxOA8jp6QR59ujw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTkCThAAoJEOVv75VaS+3OAbMP/ja0LAPE5Dj6F6FcYAe5Lg2U
4a4Q5FvrYejhWqNhfT6XSpbcKy8YtxMqURO71E6Zp+zxfR1cbMC6nNMnUXzumTx8
JQggtMDm02q/Gn00Ug+ef+QrxFrEv/Wn54gdU5gsE/HKTz5jYIEe/LwVjeQC6ndv
+DT/vN3eOBgPhtvBOeDE5nsOpN5DxQ/FYwqfQ+zYY1/xDQY6HzmmyoUk8eohE7B7
8wNF1dL8ksf9/15XrxVLJrSHezZZXC2JmOySI/WU2wteL86c03+dzqiTQw7HCqFG
A6LJJLVj5wEYG1o9VK9Hfb8n5S+OBob+U9k488ZlkaMIFsvkfPANEHjQ464fOK/c
xP/UvUdBu14vYQXVgLooWjpMUoH5JBG83AYToPbvrMSE73aaDKVNgEHRW3Xj0Zjh
z3s8oSuq4XtP8frmQVzLvxC6oaKU7dqcaGs5TGkE45pegcd9Ixdr6LABB67n6lpm
eAe6WQaIVmgof7CzrhlpecycZPuq3njZCz7waYvxj8Ko6o7xnTlCoYfowpUihVP6
IF/UT4bomBuGLs8/zh9VP+UKis+9o/0+6dBNNNPe45lKZB3JSZX/Dtkzo8UTFyqY
d8xMPujuYHyOeHuA0o0PZg+y9crN6IXWTp9nk+ZXmo8rEaw445rLymW/do0D37YG
fppVMWmEuWUzxf62Igmf
=CRPM
-----END PGP SIGNATURE-----

--=-62guamxOA8jp6QR59ujw--
