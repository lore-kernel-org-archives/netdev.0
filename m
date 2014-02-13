From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 10/14] ethtool: Expand documentation of struct
 ethtool_stats
Date: Thu, 13 Feb 2014 22:56:08 +0000
Message-ID: <1392332168.15615.54.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
	 <1392243283.15615.14.camel@deadeye.wl.decadent.org.uk>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6BE9D4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-J3ooJB0tBba+4mA7DLTL"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56226 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751615AbaBMW4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:56:22 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6BE9D4@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-J3ooJB0tBba+4mA7DLTL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-13 at 09:17 +0000, David Laight wrote:
> From: Of Ben Hutchings
> > -/* for dumping NIC-specific statistics */
> > +/**
> > + * struct ethtool_stats - device-specific statistics
> > + * @cmd: Command number =3D %ETHTOOL_GSTATS
> > + * @n_stats: On return, the number of statistics
> > + * @data: Array of statistics
> > + *
> > + * Users must use %ETHTOOL_GSSET_INFO or %ETHTOOL_GDRVINFO to find the
> > + * number of statistics that will be returned.  They must allocate a
> > + * buffer of the appropriate size (8 * number of statistics)
> > + * immediately following this structure.
> > + */
> >  struct ethtool_stats {
> > -	__u32	cmd;		/* ETHTOOL_GSTATS */
> > -	__u32	n_stats;	/* number of u64's being returned */
> > +	__u32	cmd;
> > +	__u32	n_stats;
> >  	__u64	data[0];
> >  };
>=20
> Hmmm... Although that allows some script to generate documentation,
> for anyone looking at the heeder file it seems a retrograde step.

Really, it's not that far to look.  And this way allows explaining how
the whole thing works, not just each field in isolation.

Ben.

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-J3ooJB0tBba+4mA7DLTL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUv1NiOe/yOyVhhEJAQr1qhAAzIIfWQfuChPtav6B/r+Sn+IMW9ct1So/
gSvBP6OCDJJJlL8dwb5JokVCrCSNoHYu0KX1IenO4Hs4oyTeoSUZoWyGzSGb6WrD
TyPOceOj2FS/LO2MlmeyG4gWfj1bGmauGGs589K/Ei+y1q+Lz+5mqa8UubF9gSli
sBmpkFDjNZDIzPRCLFHi/q4/IgBFPxMXJ95qySjolzxfVoC3PJtkIT5ZxCIqTToS
ZVkutR2NJdmlGuWzph0HpA3SVKyzOXnSr9XHPXagBuWtlNdYSkrP9tZSPbgBsy77
keAM3e2SMBJ4AF+1Nf84KaH9NkJZR4YOwtWl5qaUL2jdCsOj1siipY1l9SMzHj7+
UY2rB0nuAkDVt5XRxW4RzqojB5RAcjBnvPMlnUWMkCjM9uPjO3qlQ0TRlMGIWmcb
P9Q7jOYLw9JCLJUt1aMDBx41LITrgFhH5MU51AYv1Pm0OQBdjAv0Ti42eq8xRvbY
qPe+NWs2kpL0Pnmm53S2O3IFP7gssLWd2n0I37Kbe0e31s7QNRa2uFKaymxyzAvx
hJUE/dszsNWRmfcYUp5QZDol75UmzwB62qUatgO5SrHPg87ySQOlard+Vy/k9NvA
uDO4ydw5RDtqBVuBKjqMSbp9vmm8xAwX0IjWFRrIU7QivtOSWLm46GuQeWnHbcsn
mq9W1/vNtW8=
=mudR
-----END PGP SIGNATURE-----

--=-J3ooJB0tBba+4mA7DLTL--
