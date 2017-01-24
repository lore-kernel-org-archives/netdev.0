From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH for-next V2 00/11] Mellanox mlx5 core and ODP updates
 2017-01-01
Date: Tue, 24 Jan 2017 21:58:20 +0200
Message-ID: <20170124195820.GL6005@mtr-leonro.local>
References: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
 <20170102.155341.1496970446718890403.davem@davemloft.net>
 <CALzJLG9ZBRMOVqFsTypCLV6Rrek8a9g43z0spvVKeku6WdWCTA@mail.gmail.com>
 <20170103072344.GF12077@mtr-leonro.local>
 <1485286799.43764.49.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="aziWXe2aaRGlkyg3"
Cc: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1485286799.43764.49.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--aziWXe2aaRGlkyg3
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 24, 2017 at 02:39:59PM -0500, Doug Ledford wrote:
> On Tue, 2017-01-03 at 09:23 +0200, Leon Romanovsky wrote:
> > On Tue, Jan 03, 2017 at 01:30:16AM +0200, Saeed Mahameed wrote:
> > >
> > > On Mon, Jan 2, 2017 at 10:53 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > > wrote:
> > > >
> > > > From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > > > Date: Mon,=A0=A02 Jan 2017 11:37:37 +0200
> > > >
> > > > >
> > > > > The following eleven patches mainly come from Artemy Kovalyov
> > > > > who expanded mlx5 on-demand-paging (ODP) support. In addition
> > > > > there are three cleanup patches which don't change any
> > > > > functionality,
> > > > > but are needed to align codebase prior accepting other patches.
> > > >
> > > > Series applied to net-next, thanks.
> > >
> > > Whoops,
> > >
> > > This series was meant as a pull request, you can blame it on me I
> > > kinda messed up the V2 title.
> > > Doug will have to pull same patches later, will this produce a
> > > conflict on merge window ?
> >
> > Yes, but it can be easily avoided.
> >
> > Doug,
> >
> > We have another pull request to send and we will base its code on the
> > Dave's tree instead of Linus's rc tag. In such way, you will have the
> > same commits as Dave and won't have merge failures.
> >
> > Please don't apply manually this specific patchset.
> >
> > Sorry for the inconvenience.
>
> Hi Leon and Saeed,
>
> As I understand it, Dave took this series, but I have not. =A0You were
> going to base another pull request on top of this so I could get both.

We did it, ODP was our first pull request and 4K UAR was second one.
http://marc.info/?l=3Dlinux-rdma&m=3D148398855416090&w=3D2
Dave pulled this tag:
https://git.kernel.org/cgit/linux/kernel/git/mellanox/linux.git/tag/?h=3Dml=
x5-4kuar-for-4.11

Since 4K UAR tag was based on ODP, by pulling mlx5-4kuar-for-4.11 tag you
will get ODP too.

> =A0However, I believe that was the attempt to reorg the driver pull
> request, which David NAKed. =A0

It was our third pull request
http://marc.info/?l=3Dlinux-rdma&m=3D148424983101796&w=3D2
https://git.kernel.org/cgit/linux/kernel/git/mellanox/linux.git/tag/?h=3Dml=
x5-dir-layout-reorg

> That means I have not picked this up. =A0Are
> all of the other for-next patches you posted against the RDMA list
> going to go in cleanly without this series, or should I expect
> conflicts between Dave's tree and my own?

All patches sent by me are based on mlx5-4kuar-for-4.11 tag which
exists in Dave's tree and everything will apply cleanly on your
k.o/for-4.11 branch and won't have merge conflicts between your tree and
Dave's net-next tree.

For you convenience, my submission queue can be found at:
https://git.kernel.org/cgit/linux/kernel/git/leon/linux-rdma.git/log/?h=3Dr=
dma-next

Thanks

>
> --
> Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> =A0 =A0 GPG KeyID: B826A3330E572FDD
> =A0 =A0
> Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =A01274 B826 A333 0E57 2FDD



--aziWXe2aaRGlkyg3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliHsdwACgkQ5GN7iDZy
WKeWvQ//Rjou2Ya7olZ9ng7dgv2nNdYKYORUBnYrrMJlqI4PQaEAIoJSW+M2MY5L
m5mYHONpsDljx30lBk6E8dEp4blM7CZ7k6rqR8ayK9+iOiDWqaKn93osLLvV3x19
D5Owpp1inju5JyXDfcKLEAeYbIhVx9+IMBMKugrBcQXLoeebImZhAN6S7pWSnvgV
UpoHMcYHcIE6aTzd7iDP6mI94zGjylb55sXTN95OgnRJh7z//I8UP3eFluPCpq66
Wz69tr5WZ6hBhrm2PuysA6pGnY32pMB3QKKnx005vb8uyfxrNzka18LIzW8+QHPT
7wvxtYWwf7ujG5S8Zfe7HXfIc1nDf9d7bOR4eugn+d31qgvEvaeAFNA8fSw7weZ1
EBDZoX9NhD9embCWyf7b/2al1tI9orn4yNlHm/4O3kLXpe7q73XR2ZwVcsc+Zv/Z
wgkEiOBREKja+PIkOktgHRx3WCSLnUEoscdoOboOptfm6pahVsQq00Or0OJeZUaa
wlwktpCaXAgoheZhwGsxy9YV8h6iaFWq6BH6CEwEW4J74qagCrfF6dde/FZDoON/
IIR0qmyTlM0YdMwh5y+ID4gxslshEPyHXYSrXA1HVrU9/E/fRWtm0s6TjpFpgHPi
yWjJbbqFD6iAoDBK4QjgkQVViUlsRKcXT5OUjPsLcYZRutJKXS4=
=Hh7+
-----END PGP SIGNATURE-----

--aziWXe2aaRGlkyg3--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
