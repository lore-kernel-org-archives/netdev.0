From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 16/17] d80211: fix monitor interfaces
Date: Fri, 21 Apr 2006 22:52:58 +0200
Message-ID: <1145652778.3897.43.camel@localhost>
References: <20060421201147.D4F76482CF@silver.suse.cz>
	 <1145651369.3897.33.camel@localhost>
	 <20060421224935.5acd79bf@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-aHg3kTr+2mw9noAhdIPg"
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60824 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932449AbWDUUxC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 16:53:02 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060421224935.5acd79bf@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-aHg3kTr+2mw9noAhdIPg
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-04-21 at 22:49 +0200, Jiri Benc wrote:
>=20
> "Hard" monitor mode means the card is operating in a true rfmon mode -
> i.e. you get everything on the given channel. "Soft" monitor mode means
> that you will get only frames the device is willing to give you at the
> time - this probably means only frames belonging to your BSS in case of
> fullmac cards.=20

Ok, thanks for clarifying; this description should be somewhere in the
comments or so IMHO.

> and this will work - independently of the value of monitor_during_oper.
> The difference is that in case of monitor_during_oper =3D=3D 0, you won't
> probably receive much more frames from mon0 than from sta0. But - you
> will most likely receive beacons on mon0 and also monitoring headers
> (prism2 headers presently).

This I don't understand, doesn't the UI kind of suck as opposed to just
putting the sta0 device into promisc mode?

johannes

--=-aHg3kTr+2mw9noAhdIPg
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARElGKaVg1VMiehFYAQKhfg/8CLSKvhGs+dQTRcwyL7c5hzUau0SaePnq
CglhH1HDN+jQ9sAOXwcNhv+KWAq8v/d7ydrI0uDmPEwl2BI8MqTh7NEOQUjxCDlR
q3VTdl/ywER+RLDzY/yfx2AG1ojQHQ3wQ5HJhAhPpHeqJ03jjLVrLTkvHfWQI/lu
8N9cFukrNW3lGprAYBSBEHKmlrqEF0ijXoZAW5F1++WzTbVAzRBVx4PZG9ZhSHHD
ttNuZ+RYKouJEz0DAAuNaCnNyxQgU0cQMCtvexTZeplLvA9D2QykdjiCVkaT0dan
2zD7EZ+YpZVlka3yZYoYe9izTd3oqDEjiUtKCnuNMw2lQ4pfoUeKxtSEzi7ra65q
u6TW83nhmCYZ4v22OXKbk+NnEzofSedO1G7yP7bxaPg6sDoeqah9bbhyM9yq8rYA
ecAunJx0y0KjXTBrLBpkgRNDWYGvLwjjXekMDOa7Wgd33akHSkpeiL2QhVXs6EQn
0F/8fEQaNivgQ4z8hULfxta/Uj+2h8yeoKlqYUCJjVXG0R0c39Id1skz/wYtk7QW
biX26tMgU9GOeYhnz9ynaZ9SOLVrojbQcMwVjXCY4eil+NcFCcHxFj2WUY6CwZY7
w42mutl1nzx02gq6OtAZL7gupuuFoE9/tDoRGo0ONZTKHWyekD6kgd0dWMSx+rNl
0qFa6y1E/jM=
=S0cz
-----END PGP SIGNATURE-----

--=-aHg3kTr+2mw9noAhdIPg--

