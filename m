From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] drivers/net: get rid of unnecessary
 initializations in .get_drvinfo()
Date: Wed, 14 Oct 2015 19:08:31 +0100
Message-ID: <1444846111.31451.30.camel@decadent.org.uk>
References: <1444840072-21313-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7cnamV9m/d4wyVf0YknX"
To: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36309 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751919AbbJNSIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 14:08:38 -0400
In-Reply-To: <1444840072-21313-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7cnamV9m/d4wyVf0YknX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-10-14 at 18:27 +0200, Ivan Vecera wrote:
> Many drivers initialize uselessly n_priv_flags, n_stats, testinfo_len,
> eedump_len & regdump_len fields in their .get_drvinfo() ethtool op.
> It's not necessary as these fields is filled in ethtool_get_drvinfo().
>=20
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
[...]

Acked-by: Ben Hutchings <ben@decadent.org.uk>

--=20
Ben Hutchings
[W]e found...that it wasn't as easy to get programs right as we had thought=
.
... I realized that a large part of my life from then on was going to be sp=
ent
in finding mistakes in my own programs. - Maurice Wilkes, 1949
--=-7cnamV9m/d4wyVf0YknX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVh6aH+e/yOyVhhEJAQqbDhAAkbgobRg7wbvJiRyXxIDOAwuCnXnU0cHw
80BmR6DdiWc7PzjFtwWv1gvSvrQYZxrwHaCS++uayKP0YhMoHI5zd2wb3H6jF/Vi
LHtUP9zch6daqqNHVrSk//XAE59cVIglQ/xftNj39SLKnDg70EeB9EkpVGF/4lUE
5rbFzJBmcmpJc3CbSY2IfVWsq7VG76IHQJnbrvPdlg7Ffu1BwKjZQAGcJDrJ91uw
+vbAvs4FkPivRj7S4BXa6AJ+RJcm3NLFGOLckJr2DDK2PGZBcQiCyiv0dhkdAtto
7rl+dus3o7qows3zvJsyPxEW4BeWWBXxmflvUM2baPCTD1F66r7LFS2o3sB7xfDV
DJoQnGxTQVwOKfv/GzbscMsnfGTfdectbK3PLBC2GWyvC7fyO91CHF6CNd20rNJJ
69FHmuyePJm9QrBiiJXxQl7oiOY2lZ+R9HyYgvy8syYNy1cz6JpNNce2ytFNqZmq
lGWyZ76O0Q5/NMD3PNLeibQGmHTFivC9HSt0KXd/BPrFKsJ2eNUXKy9hc0OcL7DC
jb4kHJKJkxSW0NSXoN9cycnYOB95g0fq+7dvTRAODFkw3SBcROZnz4FnWLTlemR5
zAzx3vuxQUrttpzGyTuPCivxBHRahXR9GBJFz8ngR4mW4rHmMTHcq2lMA0xF1MYy
RXXdP/FzdPU=
=2Dpv
-----END PGP SIGNATURE-----

--=-7cnamV9m/d4wyVf0YknX--
