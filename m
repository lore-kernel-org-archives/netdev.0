From: Hans Fugal <hans@fugal.net>
Subject: Re: [RFC PATCH] softmac: (v2) send WEXT assoc/disassoc events to userspace
Date: Thu, 13 Apr 2006 19:05:45 -0600
Message-ID: <20060414010545.GA10636@falcon.fugal.net>
References: <1141928917.26954.7.camel@localhost.localdomain> <1141935893.28038.2.camel@localhost.localdomain> <441091B8.4010103@lwfinger.net> <1141936896.28038.6.camel@localhost.localdomain> <1144886208.4187.26.camel@localhost> <20060413001909.GB23116@falcon.fugal.net> <1144887916.4187.28.camel@localhost> <20060413002816.GC23116@falcon.fugal.net> <1144888334.4187.32.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vkogqOf2sHV7VnPd"
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	softmac-dev@sipsolutions.net, David Woodhouse <dwmw2@redhat.com>,
	Dan Williams <dcbw@redhat.com>, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgr2.xmission.com ([198.60.22.202]:51393 "EHLO
	mgr2.xmission.com") by vger.kernel.org with ESMTP id S965047AbWDNBFz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 21:05:55 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1144888334.4187.32.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

With the patch, wpa_supplicant is able to work properly for WEP and
plaintext as tested with my bcm4306 (iBook), and the latest git.

However, and this may not be related, I still must issue an=20

    ip link set up eth1

after loading the bcm43xx module but before starting wpa_supplicant or
it will not work.=20

--=20
Hans Fugal ; http://hans.fugal.net
=20
There's nothing remarkable about it. All one has to do is hit the=20
right keys at the right time and the instrument plays itself.
    -- Johann Sebastian Bach

--vkogqOf2sHV7VnPd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFEPvVp/JjozeCq1GARAonMAKDQXqAUm6G9DZ/VonnXqdBwJNadHgCg4opI
bQFgRdTJRP5N8UOvQGrxha8=
=HySI
-----END PGP SIGNATURE-----

--vkogqOf2sHV7VnPd--
