From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH wireless-dev] d80211: Add support for user space client
	MLME
Date: Fri, 05 May 2006 12:13:14 +0200
Message-ID: <1146823994.1137.65.camel@localhost>
References: <20060503183524.GD10524@instant802.com>
	 <20060504110028.5af3a22a@griffin.suse.cz>
	 <20060504164423.GA12204@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-KGuqMULUf2qvmhkjd9tV"
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:23447 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751079AbWEEKN3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 06:13:29 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060504164423.GA12204@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-KGuqMULUf2qvmhkjd9tV
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-05-04 at 09:44 -0700, Jouni Malinen wrote:

> Yes. Currently, I'm just using a configuration file parameter for this,
> but this information should eventually be exported by the kernel code to
> allow wpa_supplicant to select which mode to use without requiring user
> configuration.

For the upcoming netlink interface, I'd suggest having a group of calls
that are needed for full-mac devices (similar to the current wext) and a
second group that are needed for soft-mlme, that way you simply try out
one for the soft-mlme and if not implemented fall back to hard, or the
other way around. Maybe.

johannes

--=-KGuqMULUf2qvmhkjd9tV
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARFslN6Vg1VMiehFYAQIZdg/6AtxwpXxrbYX3fnQyCSw0Oee1gmJ8zmQG
4dy9uA/QUKq0HpCcYF357vtMGkgCRqAShu/BjGPZut5kuIUDttWOIwvXxfJh39gA
nU8gVwnc13MaVek8EKKpFdATYWrA1eGY/00fa7SqcIWLeWq9hw4EygeouSo779TA
ny1UehGElxJ9qLtt6IxQC9aSCCez94x8mJgmpSctpprGudA9JA30jMYzwG6IY3xc
p/p1SL60kGPERpa9bYie5FUdTssy73enNM8EomzW8LEnMUP0jfOPwIqv9QKRuspE
DKJTj8CVjh2LQEbP744Q4bAESyY9BHnP/7Y7O+UPkDxYAzLtPO2y8E/A7QriU8EG
wZVZDbVSETFHEcNkFv86+7BCbL5YgqZ47V8ah9tWDYEIbp0/fZ3bGYIueC4ihImu
f//6deXwGZ85X/0gH8oLQMMH9+sFCU0EfBnB3F44TXcjPl6k2fd8ACg1JGrrzIi9
UdJPKWGd2lKjOR0dwXkhfnJIfj+TQsFQm+/6lvfVGHk4qGGFjcxwjeFL1wTkctNy
e6O6PxRfz6/9LorLspFpBfvg3bOLufj/mWs31ETZTaz1hjiDp1rRzvpBXrE21Fi2
KrIDOPOWzD7D8LPC3SoZt2qjQVSNVxeusUx4OP8+iR7wlSTng4Az3p82C580P/c+
btocmM8+kjU=
=bIHg
-----END PGP SIGNATURE-----

--=-KGuqMULUf2qvmhkjd9tV--

