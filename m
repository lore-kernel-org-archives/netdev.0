From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Mon, 25 Feb 2008 10:53:48 +0100
Message-ID: <1203933228.13162.58.camel@johannes.berg>
References: <1203589042.17534.145.camel@johannes.berg>
	 <1203616486.7181.269.camel@localhost> <47BDBC23.5080007@trash.net>
	 <20080223.200202.255773165.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bnvSr1q5xT67F9E6Deau"
Cc: kaber@trash.net, joe@perches.com, harvey.harrison@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58164 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbYBYKCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 05:02:10 -0500
In-Reply-To: <20080223.200202.255773165.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bnvSr1q5xT67F9E6Deau
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Sat, 2008-02-23 at 20:02 -0800, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 21 Feb 2008 19:00:03 +0100
>=20
> > And adds back the overhead of two completely unnecessary
> > function calls to the VLAN fastpath. How about just
> > stopping this idiocy and reverting the appropriate patches
> > to bring back MAC_FMT and use it where appropriate?
>=20
> Agreed, I'll do that.

Maybe we should just add a new printf modifier like %M for MAC
addresses? Then we could use sprintf, snprintf, printk and whatever we
please without any of the macro stuff...

johannes

--=-bnvSr1q5xT67F9E6Deau
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8KQK6Vg1VMiehFYAQJM1BAAuumyLYeltdAgtJNAl3T+0XkPBmOyKLLF
8GpM3Tls1mFeYAKFYE4rG1uz580sMnOYBNf8TCBvrdwAYW8ZWYB2S9XM2LhOOtQ7
oDuJWeP1ZPdY0ep5Lkv7OwxRFdWVzEF6qpznMTaTu5ykT5nQCOuYDsg3cgFYQUON
5Obl6YeJhjwVQQW8CjMiLIIV+ytsBX3P6TuKsMyJhzkniSt5+Bhe8WGNmw0ORnpf
hiVQVTzJSdjd7evCCFGUB/cxSfk3Xev791xdYlASJRcKNxlkXaFD8PzBunNK/naF
D2PBk58JU9JQzMMRconR+s/ZS2q1xwGb7nQYB/ssR2K+4rYlX/Wd+GGrDbK5AFwg
QgaRxWaIbJ29zQpfMvDZ9G0eBxIqaO7LKv6zH/r6a/OHbRZ4j/Hdkqa3eH/QQPaH
W1OghIVdABQLU0bI4tx6sVBeEv1eV2ZnO5u0B93e8DZCCQAoFJV9U1QfGTIP4Pkd
DLdBWe2JZEuLSZmTLbPV+u8WFVxTXsJxpkL2ppwZHjfIa8YwTxk+SS7qS3EGX8NB
pQxVbYDQJl+vFFELDLdKfPOXeXpFK8MGLAdB/ZDAkiiShi7G9Sj+SmsOBFzIo+kO
CLefnKmF432CgxzIzctDrUiU37IDpjrl9mt7vn0GzGJZEGINr6VWpGw2n2qIW5CT
Ln7xQzMAfSo=
=GkHV
-----END PGP SIGNATURE-----

--=-bnvSr1q5xT67F9E6Deau--

