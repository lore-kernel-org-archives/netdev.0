From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: remove useless driver name field
Date: Mon, 20 Nov 2006 19:40:00 +0100
Message-ID: <1164048000.9216.29.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163803835.3392.52.camel@johannes.berg>
	 <20061120183213.GB5983@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oVP7raKZi1x6cN7HR+TS"
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:22217 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966396AbWKTSlx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 13:41:53 -0500
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20061120183213.GB5983@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-oVP7raKZi1x6cN7HR+TS
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-11-20 at 10:32 -0800, Jouni Malinen wrote:
> On Fri, Nov 17, 2006 at 11:50:35PM +0100, Johannes Berg wrote:
>=20
> > struct ieee80211_ops has a driver name field that's never used.
> > Remove it.
>=20
> >  struct ieee80211_ops {
> > -	/* Driver name */
> > -	char *name;
> > -
>=20
> Is this the same name field that was in struct ieee80211_hw?

Yes, it moved here during the shuffle in patch 6.

> It was used
> and the main reason was to allow rate control algorithms to be
> implemented in a way which allows hardware specific features (e.g.,
> different TX/RX status data) to be used to optimize rate selection. I
> would not remove this field unless there is another way of allowing
> something like this to be done in the rate control modules.

Oh, I hadn't found any references to it but I guess those rate control
modules are internal. I'm fine with leaving it in.

johannes

--=-oVP7raKZi1x6cN7HR+TS
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYfaA/ETPhpq3jKURAqhVAJ40EOPPMKwBvJvHLyomPr07m5Uh7QCfbZCP
5LngF5WUIL5j5L2EgVaUQHA=
=I73Z
-----END PGP SIGNATURE-----

--=-oVP7raKZi1x6cN7HR+TS--

