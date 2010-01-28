From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] be2net: Bug fix to support newer generation of BE ASIC
Date: Thu, 28 Jan 2010 22:40:29 +0000
Message-ID: <1264718429.373.520.camel@localhost>
References: <20100128075633.GA4785@serverengines.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-zRjnjfaUMT3akKfEwSg0"
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable@kernel.org,
	stable-review@kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45938 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752583Ab0A1Wkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 17:40:36 -0500
In-Reply-To: <20100128075633.GA4785@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zRjnjfaUMT3akKfEwSg0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-01-28 at 13:26 +0530, Ajit Khaparde wrote:
> Bug fix in be2net for newer generation of BladeEngine ASIC.
[...]
> @@ -2162,6 +2168,7 @@ static int be_stats_init(struct be_adapter *adapter=
)
>  	cmd->va =3D pci_alloc_consistent(adapter->pdev, cmd->size, &cmd->dma);
>  	if (cmd->va =3D=3D NULL)
>  		return -1;
> +	memset(cmd->va, cmd->size, 0);
>  	return 0;
>  }
> =20
[...]

I don't think this does what you think it does.

Also, you should either send this patch to stable@kernel.org, or NAK the
addition of PCI ids for BladeEngine 3 in 2.6.32.7.

Ben.

--=20
Ben Hutchings
You can't have everything.  Where would you put it?

--=-zRjnjfaUMT3akKfEwSg0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS2ISW+e/yOyVhhEJAQI3zw//R1ZeypxlxPMUxlG//TvdQ0Ex6vgT5wdD
g0aX154eA8fTALUY2gE4NIlEsZ8UqoijLRo919obieGzlIjuT2gqNS0XuYtb8V1m
Nv9XVbRMhKVqBvRhq1NXO+DnavrYIWleli0CAA5tlRzJ+dLI1W4p7SyySHTaN2OV
A3tthRS1BLR4PGYI2r+zwNqUeXYSo/Rjd3f3Eq2nFTRIkrnCQ1nFOYo+SBK4qxSA
IKKE3kKyQdl+mIfdPTNcju5r42TSBpXqb8y6zVRKJgx4ZX07bFkL87um3/4IxTii
NueEGasUmSPpYJqt4P/GEIEUFLk7USFO4H2wTaQMy8WwGj2VsSrFRgpKAg/HQe5N
1ADluaYErmqj+frixMaqxrR9UJ94psMKs8QmD54PuA1Hq6GYaTkZiU+jd5BlIYG+
3hJFzl76OUc1+q/la8vSEsqPEOq9EfoXzVAu3D9fqnJU71ixPTlj7R655VEGe4xw
PYXVi24iJFl/izOfzCGy2Lz/XzrIaC4bPFMXj+I+U88ygtD29bjI62kH4VYSewk0
gs6PcmLZ49cUwu1pAyveSWdgAOBLVBgVMu3g73geY2ttj8OIaw0XIkbwMxwDb0kN
87rnxOyp6aJci9vYwP62JHqAcuY/Yi5GA5l9eMUbIb+ivkzjVFgn9Jr6UfvfHu8R
fHVfTwj5BVw=
=IhjK
-----END PGP SIGNATURE-----

--=-zRjnjfaUMT3akKfEwSg0--
