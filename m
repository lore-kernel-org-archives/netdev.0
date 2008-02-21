From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 10:54:59 +0100
Message-ID: <1203587699.17534.135.camel@johannes.berg>
References: <1203586467.20345.14.camel@brick>
	 (sfid-20080221_093434_677550_A65AEFBB)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-TTwIFCuQu1h2A98F+a62"
Cc: David Miller <davem@davemloft.net>, Joe Perches <joe@perches.com>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53930 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbYBUJzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 04:55:14 -0500
In-Reply-To: <1203586467.20345.14.camel@brick> (sfid-20080221_093434_677550_A65AEFBB)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TTwIFCuQu1h2A98F+a62
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On Thu, 2008-02-21 at 01:34 -0800, Harvey Harrison wrote:
> commit 0795af5729b18218767fab27c44b1384f72dc9ad
> Author: Joe Perches <joe@perches.com>
> Date:   Wed Oct 3 17:59:30 2007 -0700
>=20
>     [NET]: Introduce and use print_mac() and DECLARE_MAC_BUF()
>    =20
>     This is nicer than the MAC_FMT stuff.
>    =20
>     Signed-off-by: Joe Perches <joe@perches.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> Introduced:
> net/mac80211/debugfs_sta.c: In function =E2=80=98ieee80211_sta_debugfs_ad=
d=E2=80=99:
> net/mac80211/debugfs_sta.c:211: warning: statement with no effect
>=20
> Does print_mac modify the mac buffer in-place, or return a new buffer?

It modifies the buffer, and I think it's more likely that the warning
was introduced by

commit 8f789c48448aed74fe1c07af76de8f04adacec7d
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Feb 18 16:50:22 2008 -0800

    [NET]: Elminate spurious print_mac() calls.

since __pure indicates that the function has no side effects apart from
the return value (IIRC)

johannes

--=-TTwIFCuQu1h2A98F+a62
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR71KcqVg1VMiehFYAQJ7IxAAuR218Er53oqXmIi7fa8Em79aZDHa0wuk
WAwjzi7SzdPkCN8uVtn/4nLbdCoqRmRWI624B2uWd5qiI/HAT5LPzWfKuunrl/n+
OAsaxxL1YLRDvwwD3Z9RW6RaAE8D/kqV8kqOhuRAzRjzu6ZDHuSBOcVri2/8P3Ya
e+aFd/eqn8b3iLNd6zjYnAR00iOeR8+IGI8Kg42Rw+fkrzc9cHITC9HClan/IL/X
iC2Ljc0aCA4Dcb8r+e0x+S1Xso9NRWRnT6UhHJEQCql8IAf9ARobqtkl6ZK7d/yk
X8fzDcWQLnd+EKEqA3kNCG3xT2aRcIsTY+y+4A0asTTwPfvikrFYANs2WMo8ms9S
MCdIKrKfDYQvLaRV9kLEYVKwSN0+sJ0AzfQB45liz4sHFK+eb6v8v2qLlzzvLmtj
7FZQul1GF6elo53vw2SY/PCIYoVvI2HvM1eh3HQOS0+/o3ByvyEWsx9hwwg0k261
x21MsL1ZogNbAKNp7HRiL1L262xKPnuv7+ybAI6CPy/lP5iuiWnhTH2B0rfKEgWq
QdaxhlGxHEouiiLQrI4NNC7kVBYeQ4i/5KQh/Zd7eaBhdPe0IuLv62/XuQRNJQ29
zg/sXVVxvnGYaoxeO+DGVI7j2vuoDal4NHGV6EAEnRFQY7N7pAtHM45ImWO1vv7p
LSBF2TElNM8=
=cd3k
-----END PGP SIGNATURE-----

--=-TTwIFCuQu1h2A98F+a62--

