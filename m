From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 37/72] fsl_*/gianfar*/ucc_*: Move the Freescale drivers
Date: Sat, 09 Jul 2011 08:07:12 -0700
Message-ID: <1310224033.26989.20.camel@jtkirshe-mobl>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1309010363-22750-38-git-send-email-jeffrey.t.kirsher@intel.com>
	 <BANLkTikrLzkXCjzBBOwHUQZEdnzTSZv9bA@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-YYQ4lTOuMls8i8GgiN5+"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sandeep Gopalpet <sandeep.kumar@freescale.com>,
	Fleming Andy-AFLEMING <afleming@freescale.com>,
	Gridish Shlomi-RM96313 <RM96313@freescale.com>,
	Li Yang-R58472 <r58472@freescale.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>
To: Tabi Timur-B04825 <B04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21818 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754209Ab1GIPHO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 11:07:14 -0400
In-Reply-To: <BANLkTikrLzkXCjzBBOwHUQZEdnzTSZv9bA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YYQ4lTOuMls8i8GgiN5+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-06-29 at 08:39 -0700, Tabi Timur-B04825 wrote:
> On Sat, Jun 25, 2011 at 8:58 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > Move the Freescale driver into drivers/net/ethernet/freescale/ and
> > make the necessary Kconfig and Makefile changes.
>=20
> I don't have an actual objection to this, but I just don't understand
> why it's necessary.  Is this a new trend for drivers/net, to have all
> drivers grouped by manufacturer?  Or is there something special about
> Freescale?
>=20

What we are trying to do is better organize the drivers/net directory
structure.  So I am placing all the Ethernet drivers in
drivers/net/ethernet/ and so on.  Under drivers/net/ethernet/, I have
tried to organize drivers by the most appropriate way to help in
maintaining the drivers, a lot of the time it tended to be by
manufacturer.  It made sense to group all the Freescale drivers into a
common directory so that it would be easier to maintain.

--=-YYQ4lTOuMls8i8GgiN5+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOGG6gAAoJECTsCADr/EWUY/EIAJk5Ut5oCM4zbfZoPn9sFe8g
BPC2zuP4Q2lftfEAcY2oG0RvEDpn7OUw4dvpNsTL7vLDv68DRy9daUS1TLaEufk2
eDmcqBHtJwj0N+yEFycVPr2wULCcnwcZY2BaNehSejfS0F96wuD5/VYzJE2/8u8z
9qhDXoknqcl7nHdWyVdLPOiVfEAgscRp56e5yU1U1LunOAXnMKoXbiY3o1OLrOUI
5zVQ3bkZliPoU/rV9fVGlrIhnb/kL9L3lwnxya9UANXygX/Itb1WJkN9Tdixt/yp
5AEpKqaJzpyzvy1BnaOC+be2EUWqz6edvIZsvvtcPDX2u9Qthh6M1FDhI1fnru8=
=RO5Y
-----END PGP SIGNATURE-----

--=-YYQ4lTOuMls8i8GgiN5+--

