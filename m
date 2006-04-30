From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] softmac: make non-operational after being stopped
Date: Sun, 30 Apr 2006 20:06:09 +0200
Message-ID: <1146420369.17814.28.camel@localhost>
References: <20060430173353.16363886AB1@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-aFQ5DPxZ+02AfLULjTtk"
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:32698 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751216AbWD3SGV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 14:06:21 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060430173353.16363886AB1@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-aFQ5DPxZ+02AfLULjTtk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-04-30 at 18:33 +0100, Daniel Drake wrote:
> zd1211 with softmac and wpa_supplicant revealed an issue with softmac and=
 the
> use of workqueues. Some of the work functions actually reschedule themsel=
ves,
> so this meant that there could still be pending work after
> flush_scheduled_work() had been called during ieee80211softmac_stop().
>=20
> This patch introduces a "running" flag which is used to ensure that
> rescheduling does not happen in this situation.
[...]
> Signed-off-by: Daniel Drake <dsd@gentoo.org>

Acked-by: Johannes Berg <johannes@sipsolutions.net>

Not sure what state 2.6.17 is in now, but I'm thinking it's almost a
miracle people aren't hitting this more with bcm43xx. And it kills the
kernel pretty effectively too ;)

johannes

--=-aFQ5DPxZ+02AfLULjTtk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARFT8jqVg1VMiehFYAQK+5A//WAtBLRYM+VL8uSU4MkbKv2qcjzeHY/dT
5pB5d/ws7X87jbHuJKPO6Bn8ZQUis10/utkW1O/P05cTG+BXdg1b7LEVFprMPqqu
vcQ3SP12Nu9cFOeDUgUC7z6uXc03Zp+V5spFXK0wiLcQ7GxKWDz4CiGwajjz5bGU
QeoX44StEvYUxV7uLRwhWmteq0FVLH2eLaJn7LSy2iQpS+BBaEhI9FcH6G7zVgBD
X+FwcEQxjTv3haNgq9A36sT1xj9fsvIXNEiQ+2eD9rkQN53H99bb/KHPAjS09oo+
bMTXZQrpUR+XkRYl/7xLvXA0fGj4AxHwtVBWSgh4g9YJmbP9sX6NdAt8t8PM9gJC
wRLU90Zh/0XBBQB2CRyNnZgjYORkgw+Pjps+dMRzltzDurBmvwTfI4hG9jtAZBSt
QWvqK+vh9JLXW2Tl5ID+Cq+MvL0tT4JyU9WXNBkgPXQjQTDIc3bA84uERvJZk6RP
3D/jYUJFvzn8u7J2bNEhreIiVeD2IyIdo0MEap6bfhgK6lC2buKK3F+/u69KZEp7
xKdqiPxofht1StHJ8OUnyZxB6+v9jOXXPgWkq8W1/B0Pr6aF0zrPqGC/HT0Ptfak
vj6aF4KyuocoLfPYEXhjZa0amPguSIXQPQKcZLKqLaCv5KVfzhrj1t1UinzTHfli
wYReSKG6eqM=
=gxRB
-----END PGP SIGNATURE-----

--=-aFQ5DPxZ+02AfLULjTtk--

