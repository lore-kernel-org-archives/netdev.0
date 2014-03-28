From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 03/16] i40evf: Support RSS option in ethtool
Date: Fri, 28 Mar 2014 00:14:28 +0000
Message-ID: <1395965668.2898.17.camel@deadeye.wl.decadent.org.uk>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1395060316-16897-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1395082411.22343.4.camel@deadeye.wl.decadent.org.uk>
	 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D65578A60@FMSMSX113.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MoHfx8U8lHTVKMcDIlOA"
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Sullivan, Catherine" <catherine.sullivan@intel.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55357 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755487AbaC1AOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 20:14:55 -0400
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D65578A60@FMSMSX113.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MoHfx8U8lHTVKMcDIlOA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-26 at 19:21 +0000, Williams, Mitch A wrote:
>=20
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > Sent: Monday, March 17, 2014 11:54 AM
> > To: Kirsher, Jeffrey T
> > Cc: davem@davemloft.net; Williams, Mitch A; netdev@vger.kernel.org;
> > gospo@redhat.com; sassmann@redhat.com; Sullivan, Catherine
> > Subject: Re: [net-next 03/16] i40evf: Support RSS option in ethtool
> >=20
> > On Mon, 2014-03-17 at 05:45 -0700, Jeff Kirsher wrote:
> > > From: Mitch Williams <mitch.a.williams@intel.com>
> > >
> > > Add support for viewing and modifying RSS hash options and RSS hash
> > > look-up table programming through ethtool. Because the lookup table i=
s
> > > so small for the VFs (only 16 registers), we don't bother to maintain=
 a
> > > shadow table in memory, we just read and write the registers directly=
.
> > [...]
> > > +static int i40evf_get_rss_hash_opts(struct i40evf_adapter *adapter,
> > > +				    struct ethtool_rxnfc *cmd)
> > > +{
> > > +	cmd->data =3D 0;
> > > +
> > > +	/* Report default options for RSS on i40e */
> >=20
> > But you're allowing them to be changed from the defaults, so this is
> > wrong.
>=20
> Ben, I've got a question on this. Should the ETHTOOL_GRXFH option
> report what the driver and device are capable of, or should it report
> the current configuration?=20

It should report the current configuration.

> If this option is supposed to report device capabilities, how can we
> find out the current configuration? And if it's supposed to report the
> current configuration, then how do we find out the device
> capabilities?

You can't find out the device capabilities except by trial and error (or
driver-specific documentation).  Even if ETHTOOL_GRXFH did tell you
which fields *could* be included in the hash, the structure doesn't have
space to tell you which subsets are supported.

> I've been wading through the kernel source, and I see both. So I'm
> confused.
[...]

The first implementation was in niu, and in the absence of accompanying
documentation that is what I took to define the interface and what I
attempted to document in <linux/ethtool.h>.  If you think the current
kernel-doc comment on struct ethtool_rxnfc is not clear enough, please
do send a patch to improve the wording.

Ben.

--=20
Ben Hutchings
73.46% of all statistics are made up.

--=-MoHfx8U8lHTVKMcDIlOA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzS+5Oe/yOyVhhEJAQp87xAAmaitNxgkV4omoijI/izV8UoP0EJydae1
ZupsOkX3NXMvU3iohQPVDwspZk9F1NtzkYRrLI4jEyySaOHjaDrFP5u3+OVEpD5C
n8JOJjumd7xx+hDzMLyNbPfNelO/OWwPbekAl5UHrioubUIo7LSfQivf5kjo/8n0
MXZ7QyzhE83DOebrmn4/hTfngXBY/gUxE9zZhsRBurgMz6i6Nqx5ZxCc2X2yER1S
1rgDRHlwvoixTMw0oqVPMjevsF75lhQyvPqQlVTiE6P1omzugSZA31vl8rAjZwaT
U/fZTzZ/xYxBMZHBcHyAZPgbRTN0LgyQuY3E3F0U7Xg/hoAArUMQw21h0CnKBM70
jtc1LJMH+VcRi+2UDGDP9WaEq748n2bQqrMg02dRS3kKAk/FauGsTWnfY46Chr5b
zIT34Xqe+ErwbzCEa7yawEusoFs3tPvrXHZ30YuVLUN49ryfFCUH+7qGiCsJ1B3t
BRi+pLyBc4dH2BHoYAIxO+nf0+vBtFSGfI/mmO4dKHP576NG9nrI2S+DOoT3bsJB
T58b4CuJ1QfbElH8l7NOVUcr2+a6ev5pAFhk6p+Oo/ZwO+DY4vJMWnWh1U/Igm9n
/C7YWqK855RU81GQ66jpxKkuoPMt/B/sZaVtcnhbipEYrnQxHeHZFoqfSX8zygb4
HF7WYZvmaUM=
=WuGa
-----END PGP SIGNATURE-----

--=-MoHfx8U8lHTVKMcDIlOA--
