From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 1/3] netfilter: Fix copy_to_user too small size parametre.
Date: Thu, 1 Mar 2012 16:13:56 +0300
Message-ID: <20120301131356.GS1003@mwanda>
References: <1330593390-19233-1-git-send-email-santoshprasadnayak@gmail.com>
 <20120301101809.GA6488@1984>
 <20120301113736.GE22598@mwanda>
 <20120301130637.GB7429@1984>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3sseE1tnmEs+TkKq"
Cc: santosh nayak <santoshprasadnayak@gmail.com>,
	bart.de.schuymer@pandora.be, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120301130637.GB7429@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--3sseE1tnmEs+TkKq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 01, 2012 at 02:06:37PM +0100, Pablo Neira Ayuso wrote:
> > Where do we clear "m"?=20
> >=20
> > include/linux/netfilter/x_tables.h
> >    287  struct xt_match {
> >    288          struct list_head list;
> >    289 =20
> >    290          const char name[XT_EXTENSION_MAXNAMELEN];
> >    291          u_int8_t revision;
> >    292 =20
> >=20
> > There is a 2 byte holes here between "revision" and "match()".  We
> > copy three bytes past the end of name, so we include revision and
> > the hole.
> >=20
> > But maybe we memset it somewhere?  I'm not sure.
>=20
> xt_match instances are declared as static for each module so it's
> allocated in the BSS (already zeroed), is that what you mean?
>=20

Yeah.  I didn't know how that worked.  Thanks.

regards,
dan carpenter


--3sseE1tnmEs+TkKq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIbBAEBAgAGBQJPT3YTAAoJEOnZkXI/YHqRwDwP+Pj1ijiRiJvmLrbJL3k6F6GN
F1wu3t4b3XDV2vz4iObqzcPmo1SbiA3k5eMa/fnvbwJ8OpmTsae25Qj7eXHjuDQM
pUjRI/38/NUcVyJjjl9VlRjDoTuzqnF2AQaqRyTwLKI/xugTi/RtO365Atz7n5gI
yrrVfSJVwdpFzuhkmW/PNMCqDs46ncUf2uRbuwcGASdQrfl6659KNo88C/by4qJn
IBvrFCc1TCIgJvDLSKOgIIKt8StILee18JV8NG712QlOujCqazrN6i3vQ6kVAe6j
tfeXiyg2AXMZJypFi2Yskxbo7Bjrxb/SA3YJmbKntSXeFohYHw+nwQsydhtzS9FF
OvwNdnU1+V3fJ/N/kMRiIWDpQn/4epd5CcqSJ98vUJIfKpN0JN6nFiGgUebVhDI2
nvRnoLkFsmh73yB1cDoDDcZONKoYfUjfbEQmSfGGg9lU8n8neeFA03ly5edzCXuc
nGABCfYSo6+yo2yrycR9JoLsueVCsPp+dCaZzaxgoqYaB5BjkyPzxEP5Offr/mg8
8dhjlNkLAVp5kU/lmE7UhQG3l2ukYe6eRvfm4kyt3j9oMR/pKt0ZQUhx5HyqHGIC
vVe8xI4lwn/xGplwuPrCQ5oW7ylZeDcfgk3Kwhgm5sT/n0PDiZeH3Yblq2aPRm8w
bQiZwWj8Xxnq8d6Z/ZA=
=4S6b
-----END PGP SIGNATURE-----

--3sseE1tnmEs+TkKq--
