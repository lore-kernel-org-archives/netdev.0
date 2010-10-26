From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
 instead of MSI-X
Date: Wed, 27 Oct 2010 10:20:35 +1100
Message-ID: <1288135235.16778.14.camel@concordia>
References: <20101025111235.GA2024@emulex.com>
	 <20101025.120943.189699949.davem@davemloft.net>
	 <20101025223853.GD15074@solarflare.com>
	 <20101025.162535.226782713.davem@davemloft.net>
	 <1288075928.6578.185.camel@concordia>
	 <20101026133233.GH15074@solarflare.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-IL09mk74AhS4aL0t8sHe"
Cc: David Miller <davem@davemloft.net>, somnath.kotur@emulex.com,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54534 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755976Ab0JZXUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 19:20:37 -0400
In-Reply-To: <20101026133233.GH15074@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IL09mk74AhS4aL0t8sHe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-10-26 at 14:32 +0100, Ben Hutchings wrote:
> Michael Ellerman wrote:
> > On Mon, 2010-10-25 at 16:25 -0700, David Miller wrote:
> > > From: Ben Hutchings <bhutchings@solarflare.com>
> > > Date: Mon, 25 Oct 2010 23:38:53 +0100

> > Ethtool would be nice, but only for network drivers. Is there a generic
> > solution, quirks are obviously not keeping people happy.
> =20
> Since this is (normally) a property of the system, pci=3Dnomsi is the
> generic solution.

Sort of, it's a big hammer. Did all these driver writers not know about
pci=3Dnomsi or did they prefer to add a parameter to their driver for some
reason?

> [...]
> > Misc:
> >   sound/pci/hda/hda_intel.c:MODULE_PARM_DESC(enable_msi, "Enable Messag=
e Signaled Interrupt (MSI)");
> >   drivers/message/fusion/mptbase.c:MODULE_PARM_DESC(mpt_msi_enable_spi,=
 " Enable MSI Support for SPI \
> >   drivers/message/fusion/mptbase.c:MODULE_PARM_DESC(mpt_msi_enable_fc, =
" Enable MSI Support for FC \
> >   drivers/message/fusion/mptbase.c:MODULE_PARM_DESC(mpt_msi_enable_sas,=
 " Enable MSI Support for SAS \
> >   drivers/net/myri10ge/myri10ge.c:MODULE_PARM_DESC(myri10ge_msi, "Enabl=
e Message Signalled Interrupts");
> [...]
>=20
>   drivers/net/sfc/efx.c:MODULE_PARM_DESC(interrupt_mode,
>   drivers/net/sfc/efx.c-                 "Interrupt mode (0=3D>MSIX 1=3D>=
MSI 2=3D>legacy)");

Well spotted.

cheers



--=-IL09mk74AhS4aL0t8sHe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzHYkMACgkQdSjSd0sB4dKCDACaA/1bRn8XzkYqMkXSFE0uNcX9
nygAnRCKsKfZMp8LVjQOo2xXbQiAACPv
=lTCG
-----END PGP SIGNATURE-----

--=-IL09mk74AhS4aL0t8sHe--

