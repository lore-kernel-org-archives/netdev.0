From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Please make CONFIG_CFG80211 harder to enable
Date: Sun, 10 Dec 2006 14:17:33 +0100
Message-ID: <1165756653.3131.1.camel@johannes.berg>
References: <1165654123.2816.29.camel@portland.localdomain>
	 <20061209160640.GA3365@tuxdriver.com>
	 <87hcw49rg8.fsf@briny.internal.ondioline.org>
	 <20061210031202.6rgqw4go8ck48kks@webmail.spamcop.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tqKc+Vqs0SlxaOpaQLXZ"
Cc: Paul Collins <paul@briny.ondioline.org>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:54377 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760423AbWLJNSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 08:18:00 -0500
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <20061210031202.6rgqw4go8ck48kks@webmail.spamcop.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-tqKc+Vqs0SlxaOpaQLXZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-12-10 at 03:12 -0500, Pavel Roskin wrote:

> Sorry, it looks like the evil setting is actually CONFIG_CFG80211_WEXT_CO=
MPAT.
> I should have checked it better.  Please look for the code around the
> cfg80211_wext_ioctl call in dev_ioctl(), net/core/dev.c.
>=20
> The logic now is to try the compatibility code first.  I think it's wrong=
, at
> least for now.  I think the compatibility code should only be invoked if =
the
> native WE support failed for the request.  Or maybe if the cfg80211 suppo=
rt is
> present for the driver.

No, it's correct. Re-read the code.

> Yes.  And I could trace "iwgetid -m ath0" to cfg80211_wx_get_mode() in
> net/wireless/wext-compat.c, which returns -ENOSYS unconditionally.  ath0 =
is
> from current MadWifi.

Now trace it further and notice that on -ENOSYS the original WE is
invoked.

johannes

--=-tqKc+Vqs0SlxaOpaQLXZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFfAjs/ETPhpq3jKURAnQfAJ98JfA02XdNGXBqnj1FyyapEY8n1gCgnTHq
drmS1gixBqcubeX8LI++YjI=
=GOXv
-----END PGP SIGNATURE-----

--=-tqKc+Vqs0SlxaOpaQLXZ--

