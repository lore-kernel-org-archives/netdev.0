From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Fri, 15 Jul 2016 18:47:48 +0300
Message-ID: <20160715154748.GA10556@leon.nu>
References: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
 <20160715050005.GD30603@leon.nu>
 <20160715151759.lfsncj62gi2b7mas@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Cc: Netanel Belgazal <netanel@annapurnalabs.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aliguori@amazon.com, ben@decadent.org.uk, romieu@fr.zoreil.com,
	rami.rosen@intel.com, antoine.tenart@free-electrons.com
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160715151759.lfsncj62gi2b7mas@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 15, 2016 at 08:17:59AM -0700, Benjamin Poirier wrote:
> On 2016/07/15 08:00, Leon Romanovsky wrote:
> > On Thu, Jul 14, 2016 at 09:46:14AM +0300, Netanel Belgazal wrote:
> > > This is a driver for the ENA family of networking devices.
> > >=20
> > > Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> > > ---
> > >=20
> > > Notes:
> >=20
> > ...
> >=20
> > >     - Increase driver version to 1.0.2
> >=20
> > ...
> >=20
> > > +static void ena_get_drvinfo(struct net_device *dev,
> > > +			    struct ethtool_drvinfo *info)
> > > +{
> > > +	struct ena_adapter *adapter =3D netdev_priv(dev);
> > > +
> > > +	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
> > > +	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
> >=20
> > Does module version give anything valuable in real life usage?
> > Do you plan to bump version after every patch?
> >=20
> > Hint, NO.
> >=20
> [...]
> > > +
> > > +#define DRV_MODULE_VER_MAJOR	1
> > > +#define DRV_MODULE_VER_MINOR	0
> > > +#define DRV_MODULE_VER_SUBMINOR 1
> > > +
> > > +#define DRV_MODULE_NAME		"ena"
> > > +#ifndef DRV_MODULE_VERSION
> > > +#define DRV_MODULE_VERSION \
> > > +	__stringify(DRV_MODULE_VER_MAJOR) "."	\
> > > +	__stringify(DRV_MODULE_VER_MINOR) "."	\
> > > +	__stringify(DRV_MODULE_VER_SUBMINOR)
> > > +#endif
> > > +#define DRV_MODULE_RELDATE      "22-JUNE-2016"
> >=20
> > Please remove it, driver version is useless in real life kernel usage.
> >=20
>=20
> The release date might be a bit overkill but the driver version is
> useful in the context of distribution kernels where users sometimes mix
> and match newer drivers (ex: the intel sf.net drivers) with older
> kernels. When a bug is reported, a quick look at the module version can
> help indicate the provenance of the driver.

We already discussed it in a number of occasions, for example this is
response of Greg Kroah-Hartman to similar attempt to bump driver version
[1].

And as I said before, mostly this driver will change without any
reflection in driver version.

[1] http://www.spinics.net/lists/linux-rdma/msg29855.html

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXiQWkAAoJEORje4g2clin+dEQAMIndaPREeg3MOTisDMNJwAG
pR5Ai2O8E9JaMod3a0Erq9EEmkHtX3F9E8l2mU3OAEKIeIfSW0v9czmtCWqoK5MD
3CkHl5OPlHq7xYmJFSGCltwjJeRVR29PiRI80e/n8g5KUbpZ4s8ySxQ22bhLsJKq
eeizkDITaIqnYDGyyyqvHigjvyRzuBiwf4cvvqIgipzZ6oBvl9iP1Vo0tRoqTTeR
7jNi6/UjfsAle7SM9Rt9HCNcVwLZxNkmRJwLn8iK4ZrOkjUvUGouudfjlIpWQyTZ
O+GIeh7+pd3t2YrzbZ9F6YZPttbt81cihP8OA6MKv0Oe9F8f/JB/r68A5IpwmPIU
rc88wuMKPrg+6tJE57HUgDyWjYzsyw28DSC7V5pdEIA9GVj8Z2F0OFvwpQRow6Uf
cfjyZVNB3xm0i4FbEviSSZhVX39h+xHchhXe7UzSfexfUrw1iAzHsy6h3tB3Eh+i
+aX9iyNVDtdb/MekcmTe6cff+jELoTd6TP7a3SW0x3WyUoMloJ5ZSirDoOHsdgHw
HAt6Znw8Dble9Y49Qos06SsbuPcaPyQ6XHzRknXFglLs7Q4fHpkaTTAXj7EvPZzB
ZvAifdlgUJ69OqH+HcqpXu+YhZYKkMg94GiQ7h8D7boaSi7XHaokW/u9j5QZpHet
rlzJzVD/kv7lTQ61yReb
=yUuo
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--
