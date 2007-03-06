From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [2.6.21 patch] unconditionally enable SYSFS_DEPRECATED
Date: Tue, 06 Mar 2007 14:20:50 +0100
Message-ID: <1173187250.3403.7.camel@johannes.berg>
References: <20070304220857.GH23311@waste.org>
	 <1173051564.6131.13.camel@johannes.berg> <20070305002550.GI23311@waste.org>
	 <20070305011729.GB7681@kroah.com> <20070305125950.GC26781@thunk.org>
	 <20070305185813.GA31465@kroah.com> <20070305234052.GR3441@stusta.de>
	 <20070306000722.GA11436@kroah.com> <20070306013020.GN23311@waste.org>
	 <20070306015638.GA23756@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-15IQDM44rstVXjWudRV8"
Cc: Matt Mackall <mpm@selenic.com>, Adrian Bunk <bunk@stusta.de>,
	Theodore Tso <tytso@mit.edu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yi.zhu@intel.com, jketreno@linux.intel.com,
	linux-wireless <linux-wireless@vger.kernel.org>, akpm@osdl.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38291 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964981AbXCFNVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 08:21:53 -0500
In-Reply-To: <20070306015638.GA23756@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-15IQDM44rstVXjWudRV8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-03-05 at 17:56 -0800, Greg KH wrote:

> Theory F:  It broke because you are using NetworkManager for your
> network devices and the patches that fix this have not made it into a
> real release?
>=20
> I'm just guessing, but does anyone who is having this problem, NOT using
> NetworkManager?
>=20
> I'm running an old version of HAL just fine, but I'm not using
> NetworkManager here.

Greg, HAL itself isn't the problem. The problem is that older versions
of HAL ignore all network devices when this option is not set and thus
network manager can't pick them up.

johannes

--=-15IQDM44rstVXjWudRV8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF7Wqy/ETPhpq3jKURAmEZAKCE3mEn0TqexYxE2hmmdxG99XgqKwCgpetD
p8rd51qaqJYQZRMK+qUJK60=
=mau2
-----END PGP SIGNATURE-----

--=-15IQDM44rstVXjWudRV8--

