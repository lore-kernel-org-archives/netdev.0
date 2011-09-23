From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: RE: [net-next 1/8] pci: Add flag indicating device has been
 assigned by KVM
Date: Fri, 23 Sep 2011 08:45:09 -0700
Message-ID: <1316792710.2182.124.camel@jtkirshe-mobl>
References: <1316599974-23205-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316599974-23205-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAL3LdT7jDfytZD7WESmiHxvpmxKTEZ=uWRjzgsR9e4GtBPE31A@mail.gmail.com>
	 <1316762872.23371.88.camel@zakaz.uk.xensource.com>
	 <43F901BD926A4E43B106BF17856F0755019C518C0E@orsmsx508.amr.corp.intel.com>
	 <1316790220.23371.105.camel@zakaz.uk.xensource.com>
	 <43F901BD926A4E43B106BF17856F0755019C518C47@orsmsx508.amr.corp.intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-D8E7GmkrMU5h+JFUqnIf"
Cc: Ian Campbell <ijc@hellion.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019C518C47@orsmsx508.amr.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-D8E7GmkrMU5h+JFUqnIf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-09-23 at 08:11 -0700, Rose, Gregory V wrote:
> > -----Original Message-----
> > From: Ian Campbell [mailto:ijc@hellion.org.uk]
> > Sent: Friday, September 23, 2011 8:04 AM
> > To: Rose, Gregory V
> > Cc: Kirsher, Jeffrey T; davem@davemloft.net; konrad.wilk@oracle.com; Je=
sse
> > Barnes; netdev@vger.kernel.org; gospo@redhat.com; linux-
> > pci@vger.kernel.org
> > Subject: RE: [net-next 1/8] pci: Add flag indicating device has been
> > assigned by KVM
> >=20
> > On Fri, 2011-09-23 at 07:41 -0700, Rose, Gregory V wrote:
> > > > -----Original Message-----
> > > > From: Ian Campbell [mailto:ijc@hellion.org.uk]
> > > > Sent: Friday, September 23, 2011 12:28 AM
> > > > To: Kirsher, Jeffrey T
> > > > Cc: davem@davemloft.net; konrad.wilk@oracle.com; Jesse Barnes; Rose=
,
> > > > Gregory V; netdev@vger.kernel.org; gospo@redhat.com; linux-
> > > > pci@vger.kernel.org
> > > > Subject: Re: [net-next 1/8] pci: Add flag indicating device has bee=
n
> > > > assigned by KVM
> > > >
> > > > I suppose by that measure the comment could be less KVM specific:
> > > > > +       /* Provide indication device is assigned by KVM */
> > > > > +       PCI_DEV_FLAGS_ASSIGNED =3D (__force pci_dev_flags_t) 4,
> > >
> > > We can resubmit with a more generic comment, maybe this:
> > >
> > > /* Provide indication device is assigned by a Virtual Machine Manager=
 */
> >=20
> > Sounds good to me.
>=20
> Dave, Jeff,
>=20
> Should I resubmit the patch or would it be more convenient to post a foll=
ow on patch that fixes up the comment?  Either way is fine by me.
>=20
> - Greg
>=20

let's fix up the patch in my tree and add Jesse Barnes's ACK at the same
time.

--=-D8E7GmkrMU5h+JFUqnIf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOfKmFAAoJECTsCADr/EWUlIkH/iAnbgr29FyQSgdTtpywBvyn
//D8DuzrEGMNWt8MxrwvWpUYm5NumqUO2TChBQkcVQZQ5w3g3BKExPS28MEU78aT
UsO72rhoQLFwclBpnFcx1FWdShjJNRSWJp735VcQprWMkFY8sON65r6hV9vG+WoY
uDY7a/TovAzkJmSF3vc8aPhQkEUfOcNAM+eRQZRdpGfOZX0nN+QsNkS/5BmvboW4
kpXhk9B7qm2Uax+EguYGhtQVnlCd/80x4sJ2E0/O0AxX7/y2m1s+MNWCxGfHblaT
422U8ltNwDIyK25TNgdobc23ICoRSF/omRF6h5s95kXCFxD/OhwBCBEe0RGGrMI=
=6c3p
-----END PGP SIGNATURE-----

--=-D8E7GmkrMU5h+JFUqnIf--
