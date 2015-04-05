From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3/3] ethtool: Add support to get expansion ROM version
 in ethtool getdrvinfo
Date: Sun, 05 Apr 2015 04:05:23 +0100
Message-ID: <1428203123.11260.161.camel@decadent.org.uk>
References: <1423054176-26420-1-git-send-email-hariprasad@chelsio.com>
	 <1423054176-26420-4-git-send-email-hariprasad@chelsio.com>
	 <20150325083722.GA5303@hariprasad-pc.asicdesigners.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0F+gLqxs2dcv/PUKhu8V"
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58824 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752092AbbDEDFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 23:05:36 -0400
In-Reply-To: <20150325083722.GA5303@hariprasad-pc.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0F+gLqxs2dcv/PUKhu8V
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-03-25 at 14:11 +0530, Hariprasad S wrote:
> On Wed, Feb 04, 2015 at 18:19:36 +0530, Hariprasad Shenai wrote:
> > Rename the reserved1 field of ethtool_drvinfo to erom_version, and use =
it to get
> > the expansion ROM version of the adapter.
> >=20
> > Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> > ---
> >  ethtool-copy.h |    3 ++-
> >  ethtool.c      |    2 ++
> >  2 files changed, 4 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/ethtool-copy.h b/ethtool-copy.h
> > index 61b78fc..e2df0e5 100644
> > --- a/ethtool-copy.h
> > +++ b/ethtool-copy.h
> > @@ -148,6 +148,7 @@ static __inline__ __u32 ethtool_cmd_speed(const str=
uct ethtool_cmd *ep)
> >   *	not be an empty string.
> >   * @version: Driver version string; may be an empty string
> >   * @fw_version: Firmware version string; may be an empty string
> > + * @erom_version: Expansion ROM version string; may be an empty string
> >   * @bus_info: Device bus address.  This should match the dev_name()
> >   *	string for the underlying bus device, if there is one.  May be
> >   *	an empty string.
> > @@ -176,7 +177,7 @@ struct ethtool_drvinfo {
> >  	char	version[32];
> >  	char	fw_version[ETHTOOL_FWVERS_LEN];
> >  	char	bus_info[ETHTOOL_BUSINFO_LEN];
> > -	char	reserved1[32];
> > +	char	erom_version[32];
> >  	char	reserved2[12];
> >  	__u32	n_priv_flags;
> >  	__u32	n_stats;
> > diff --git a/ethtool.c b/ethtool.c
> > index bf583f3..b7d2206 100644
> > --- a/ethtool.c
> > +++ b/ethtool.c
> > @@ -701,6 +701,7 @@ static int dump_drvinfo(struct ethtool_drvinfo *inf=
o)
> >  		"driver: %.*s\n"
> >  		"version: %.*s\n"
> >  		"firmware-version: %.*s\n"
> > +		"expansion-rom-version: %.*s\n"
> >  		"bus-info: %.*s\n"
> >  		"supports-statistics: %s\n"
> >  		"supports-test: %s\n"
> > @@ -710,6 +711,7 @@ static int dump_drvinfo(struct ethtool_drvinfo *inf=
o)
> >  		(int)sizeof(info->driver), info->driver,
> >  		(int)sizeof(info->version), info->version,
> >  		(int)sizeof(info->fw_version), info->fw_version,
> > +		(int)sizeof(info->erom_version), info->erom_version,
> >  		(int)sizeof(info->bus_info), info->bus_info,
> >  		info->n_stats ? "yes" : "no",
> >  		info->testinfo_len ? "yes" : "no",
> > --=20
> > 1.7.1
> >=20
>=20
>=20
> Hi Ben,
>=20
> Can you pull this one to the ethtool repo?

Applied, thanks.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-0F+gLqxs2dcv/PUKhu8V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSCmeee/yOyVhhEJAQpplg//fPK8YCJj+23c4Dei0xdPFDsbZCetVU1N
fhA+cQ/q1HQGReBp3ETkqnO1SPALT6SnRJ3JPdeF7iojPJbEZ8TKXTmVaHD5plGU
BLCdGb/R9ITtgfNvkY7s2FT+YqrP6gLQjY2NSF3NkktaV4xlwLObwlG2xXpzZ+IO
lVYMF7R2Iytbwej/1sP4LYe4z/szsEL30ZJGEhgchlBnmrl3kh5Rq9aHfVgMKu+Q
HPBrcNxihS0blhtXqQ0+a0qPuSEYjbn5o3CH1fGUWPot3bje2ad75Cc7q/vpj06m
Xt04CWAbm8N1JCm8jAyBkLBulbxepYCX0o6BK084eA/Z0wBzMEi+WAlYjDSXlb+z
yyu9KW43o2h82T1ejf282GItSZOibndR5O++uIzxiejzCda1h8+Mttz3Xl8Ksrr/
sDhoh2c7UyTqWkopkxtGxqAPWoWVCZK071gOxvV8ISrPKmdqk0QD5SVmqqGo9Haq
hV9qsnIhQZa0MtXzL9RbRaKeXlc7yTarM9wdNHbOs+VzZNvZXXpe0VBssLYrPdo5
5chHAroKkpnQ0znOg2JNtViOkOSIuVpO1P9GrF56paKlLHQlnf8p8/VAWxw7TnHL
ogZqncGWFi7e8SgaL3t3nVy35ZGaMzK1rd7kf19hinN3L+kLN2UzczCVE+Pa76o/
ZVs02yNK7dg=
=H7TH
-----END PGP SIGNATURE-----

--=-0F+gLqxs2dcv/PUKhu8V--
