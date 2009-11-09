From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Mon, 09 Nov 2009 18:46:11 +0100
Message-ID: <1257788771.29454.191.camel@johannes.local>
References: <1254473048.3959.76.camel@johannes.local>
	 <4AF43EF9.3020707@trash.net> <1257521204.29454.31.camel@johannes.local>
	 <4AF442C2.9040704@trash.net> <1257762132.29454.161.camel@johannes.local>
	 <4AF8122F.9060807@trash.net> <1257771787.29454.173.camel@johannes.local>
	 <4AF816D3.7000304@trash.net> <1257785502.29454.178.camel@johannes.local>
	 <4AF849F6.4050308@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-70D0TRppznVUYudFdJjp"
Cc: netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58357 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbZKIRqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 12:46:38 -0500
In-Reply-To: <4AF849F6.4050308@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-70D0TRppznVUYudFdJjp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-11-09 at 17:57 +0100, Patrick McHardy wrote:

> > Oh? So on which sockets can I rely on it being used? After sending at
> > least one unicast message into the kernel? This seems to depend on pid
> > being assigned -- when is that?
>=20
> All unicast sockets that have either manually or automatically
> bound. Automatic binding happens when sending the first message
> or when calling connect().
>=20
> Before that, your code can't know of the sockets existance, so
> I guess this should be fine.

Ah, yes, of course... that's part of the boilerplate code to use generic
netlink so I always forget about what exactly is going on there :)

Thanks!

johannes


--=-70D0TRppznVUYudFdJjp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK+FVfAAoJEODzc/N7+Qmaum0QANIZR9itLx2E8vafrgwCUWX4
ImhKMIBAWtAo9fI6yWhNBL28SYDbmW31niu3+S1s1OpZbP3FAlndXvZLq76U1Sch
SoBJq4C5Hb9C/yjDy2SuVqnpLXXWIwqFLia++hHzxhRM3SMSYuhGOGDbGxECmqno
4yoInSWkIjKBcYZdsTUoGvKQzF3VVJaLL4aUnf01k0VxnxipdhH5tal0g+VQ18oj
3FYmw872Z4ElOH+Zb/bQc4DE2BJyCZpyYEGaMbm+y0ElDTrX+wrLhnzt+PaiywPX
1M+iq9xk4e0Vod1zPpCFDmXl3nJOk4oxpJdfvWTJH0LrCy2SIEQzU3D9yvCbVDiP
FjKfw8e88nqSuDX6FdKdKN7NzYlrLXFsOQqernvwDuZGNCLrRhFm22apmxhh2FNF
BW+E9MOj7JwSMu1gNzbn6mSPRR2RyXlVSB77Mh+yBMTVjwJ6U/c5eDkkP8Ee5UPz
SS0OGt20G8Vxco7lr/hnA+JgopMBR0Qc8lc8g9mLPbhIbmh2Dr0yVpV7O1NEDfcA
hC+j1dLgzGgK0f4/aYHg0SQhYib9KiVrJZRrKgJj78v/K9nzmV8FxWNFr5xEVSsh
T1txIjGrZhfDUwFaij7mvshr35bT0dC8UUgKwuUhgC01lMAKdq+PiqND2pRFMPHN
JGtBjh5XlfVXiRibn6n2
=Uypm
-----END PGP SIGNATURE-----

--=-70D0TRppznVUYudFdJjp--

