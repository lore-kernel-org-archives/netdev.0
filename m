From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 3/3] d80211: fix workqueue breakage
Date: Thu, 14 Dec 2006 01:30:32 -0500
Message-ID: <200612140130.37534.flamingice@sourmilk.net>
References: <200612121255.58183.flamingice@sourmilk.net> <20061213191330.450865b1@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1399883.cXcSsj7rqZ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:40024 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752026AbWLNGa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 01:30:59 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061213191330.450865b1@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1399883.cXcSsj7rqZ
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 13 December 2006 13:13, Jiri Benc wrote:
> On Tue, 12 Dec 2006 12:55:53 -0500, Michael Wu wrote:
> > -			schedule_work(&local->scan_work);
> > +			schedule_work(&local->scan_work.work);
>
> Hm, what is the preferred way here:
> schedule_work(some_delayed_work.work)
> or
> schedule_delayed_work(some_delayed_work, 0)?
>
Hm, according to David Howells, the second is preferred. I'll update the=20
workqueue patch tomorrow.

Thanks,
=2DMichael Wu

--nextPart1399883.cXcSsj7rqZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFgO+NT3Oqt9AH4aERApRcAJwOGAkkuaofDYD3/Fk1WqakuyPfvQCfR77H
YrSu0i3Lnt19jGirIWp3q58=
=228D
-----END PGP SIGNATURE-----

--nextPart1399883.cXcSsj7rqZ--
