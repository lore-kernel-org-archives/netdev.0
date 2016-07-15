From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Fri, 15 Jul 2016 08:17:59 -0700
Message-ID: <20160715151759.lfsncj62gi2b7mas@f1.synalogic.ca>
References: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
 <20160715050005.GD30603@leon.nu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="25jznh7lf2seda6u"
Cc: Netanel Belgazal <netanel@annapurnalabs.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aliguori@amazon.com, ben@decadent.org.uk, romieu@fr.zoreil.com,
	rami.rosen@intel.com, antoine.tenart@free-electrons.com
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160715050005.GD30603@leon.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--25jznh7lf2seda6u
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2016/07/15 08:00, Leon Romanovsky wrote:
> On Thu, Jul 14, 2016 at 09:46:14AM +0300, Netanel Belgazal wrote:
> > This is a driver for the ENA family of networking devices.
> >=20
> > Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> > ---
> >=20
> > Notes:
>=20
> ...
>=20
> >     - Increase driver version to 1.0.2
>=20
> ...
>=20
> > +static void ena_get_drvinfo(struct net_device *dev,
> > +			    struct ethtool_drvinfo *info)
> > +{
> > +	struct ena_adapter *adapter =3D netdev_priv(dev);
> > +
> > +	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
> > +	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
>=20
> Does module version give anything valuable in real life usage?
> Do you plan to bump version after every patch?
>=20
> Hint, NO.
>=20
[...]
> > +
> > +#define DRV_MODULE_VER_MAJOR	1
> > +#define DRV_MODULE_VER_MINOR	0
> > +#define DRV_MODULE_VER_SUBMINOR 1
> > +
> > +#define DRV_MODULE_NAME		"ena"
> > +#ifndef DRV_MODULE_VERSION
> > +#define DRV_MODULE_VERSION \
> > +	__stringify(DRV_MODULE_VER_MAJOR) "."	\
> > +	__stringify(DRV_MODULE_VER_MINOR) "."	\
> > +	__stringify(DRV_MODULE_VER_SUBMINOR)
> > +#endif
> > +#define DRV_MODULE_RELDATE      "22-JUNE-2016"
>=20
> Please remove it, driver version is useless in real life kernel usage.
>=20

The release date might be a bit overkill but the driver version is
useful in the context of distribution kernels where users sometimes mix
and match newer drivers (ex: the intel sf.net drivers) with older
kernels. When a bug is reported, a quick look at the module version can
help indicate the provenance of the driver.

--25jznh7lf2seda6u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXiP6iAAoJEGiQW0t92FktA0AQAI+Erx1zeoEKR/IO/oVEvWfS
Qm14NlLPQtYWBN4sMgmTcPz4MpaTXE55N4oh9Cq0Fag169bIYE7uMw3c+ylOkQro
D2ZQK6gPdS/45SZem5jmrSlKCqin1wdn/8LxXOl/yq8wfngpgGllHObIgbHcOQcR
KsioNxDPDMbWVxyDzVSPAV7BCbJHYo8ju4gJagKfKQC/23xNmrjH7hms9KfJPhju
JT3FiBEsGvcIk+CgXaq6kqzjG7HfZSY9CdD/m2OWJmc3nxb2UYL0zQxx2bso76lm
yUptSzl0JKXQfs7hmpM178psxMojWXIeEWhzySMGfu/ClL+yagVbUSc4mMYTvhF0
av+9q3eNs9YJrj/sBqGvRwvfXIzMCveKlnRCbTpZaCdgC/uBBHM9tTClWthPSC6x
n7aVhRRbtKdoyYFb4lg3FbymxY1civGEWD/RY0/Unqk142WeqYiQWRj4+cn24d9q
KrCKYEydSOEQuIaG8GDWPdbJpccEM+8oEXEZAoWrmoUo8mmQC5Nl0io+yAKBZpfd
M9E2E0nEYw6XJ7tNOqcKoGty5JJhYbEE5jd85r7iLssQvcepWketBv6KhRYdFoy3
TpeXKUVP4drQ0EFwrdCh/wpfSobsqpZ+RirH5ecZca/4/zdeWbiirT/js1iGbfLB
rOiSjHmwz7lGMRSAHDjw
=6UAv
-----END PGP SIGNATURE-----

--25jznh7lf2seda6u--
