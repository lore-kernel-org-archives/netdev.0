From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: rtnetlink: propagate error from dev_change_flags in
	do_setlink()
Date: Sun, 16 Nov 2008 14:16:08 +0100
Message-ID: <1226841368.3644.6.camel@johannes.berg>
References: <1226841029.3644.2.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-LL48Dp5JTdhz+KJJtq7k"
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:50051 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbYKPNQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 08:16:14 -0500
In-Reply-To: <1226841029.3644.2.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LL48Dp5JTdhz+KJJtq7k
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-11-16 at 14:10 +0100, Johannes Berg wrote:
> Unlike ifconfig, iproute doesn't report an error when setting
> an interface up fails:
>=20
> (example: put wireless network mac80211 interface into repeater mode
> with iwconfig but do not set a peer MAC address, it should fail with
> -ENOLINK)
>=20
> without patch:
> # ip link set wlan0 up ; echo $?
> 0
> #=20
>=20
> with patch:
> # ip link set wlan0 up ; echo $?
> RTNETLINK answers: Link has been severed
> 2
> #=20
>=20
> Propagate the return value from dev_change_flags() to fix this.
>=20
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Tested-by: Johannes Berg <johannes@sipsolutions.net>
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Maybe add
Cc: stable@kernel.org [since the beginning of time^Wgit]

when committing? Not sure it's appropriate for stable since so far
nobody complained, I suspect people just use the ioctl anyway.

johannes

--=-LL48Dp5JTdhz+KJJtq7k
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJIB0TAAoJEKVg1VMiehFYD6sQAMTuF/Z4I5AWutx68rFIO1xI
g0ey4S2999GfViHJPUNnnAfKa4OdZrUYvofIOd2lHV+oKy+LZpd90P207P9KwF4U
zslGmr6mVa1ht3pMwO2vFiZd2obYBq4x4GTok4pfkk6M6qM/CSNAvW0y1pf60vrT
HuPqpMkrO9h9xpNQoASsSZIdJFbTL3ZV0D6iZrLpZ3W3/PVJLzAiYCffhDJuP0k3
aOrNlbQQy3+nNx13hKHtjhyZcBBUNN88ESWk+FObsl6HG5QhL96PQxHoCgXiGcll
ejwuK7XQ0lu9aD20l9DN6MKuSV/NxsawtN2IP0kqRU+JPmMMf/oCUQsgYTotZVn0
rH01Gpp+sM+lB0MJ7AIyCuoYOeeuoUHJ5tazWsLxL/eqX8MT2AYAeMlTEXp7YPL1
SddxLp2ez4l1ysP+eTdriwtHKh+DcywdJyzUwyFu9r3GZbVF3JCpP/L49TjIuHpR
rQyP1F29xLPONFN4i5zmdcghuVRj87jbbFaF79oL7r+OB71eGOGZBlf4ZrZ+4x1l
IGGWhYWZhfRm+x4V7E4Y+jx5bG/lZEWp1Qiyhou1JJ054qZyWW6LmHuXkH9YBLHF
SZRmJR0ohjn8n2JQvTL8pyLaH1BfQUxLbLCJdjExs9Lktb2L3Q9tFLrjsCVp9I+J
vbjcjBqSRat0tu7iWVzr
=qM+s
-----END PGP SIGNATURE-----

--=-LL48Dp5JTdhz+KJJtq7k--

