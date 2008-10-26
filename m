From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Sun, 26 Oct 2008 09:38:05 +0100
Message-ID: <1225010285.3478.33.camel@johannes.berg>
References: <1224892008.3919.27.camel@johannes.berg>
	 <49035AF0.6040700@anduras.de> <1225008096.3478.3.camel@johannes.berg>
	 <20081026.010329.11475786.davem@davemloft.net>
	 <1225009308.3478.22.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pnQvORXoma+nxB0br2qm"
Cc: anders@anduras.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40885 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbYJZIiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 04:38:11 -0400
In-Reply-To: <1225009308.3478.22.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pnQvORXoma+nxB0br2qm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-10-26 at 09:21 +0100, Johannes Berg wrote:

> > It would be a nice future project for someone.  But don't worry
> > about it for now.
>=20
> Of course, actually adding, say, %p4 and %p6 would be trivial, but
> making lots of code use it so it's useful would be another mass
> conversion I'm not too keen to do again right away :)

And for IPv4 you can do it in a similar way, except for HIPQUAD which
you'd have to actually replace in the code, but there are less than 20
instances of it. Maybe use SPECIAL to indicate host byte order or
something, I'll leave that to the interested, unless I get really bored
next week (I'm kinda bored right now but don't have access to a fast
build machine ;) )

johannes

--=-pnQvORXoma+nxB0br2qm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBCxpAAoJEKVg1VMiehFYKYUQAMLFWFpaM/SOZIHl6cufmQOz
FswLeSMwvXeyyoD3rz8LGAPCIuckZvbW4f132qPn8namzK0Ps7b74zZ8jlkddi/U
CM85GraXFGo1rQqU6EtVwbX/X/OAzsvvhFyXr2Nhtzwl3F06yuyW6TVXhTBWG5F9
hl0mOWhNN/E5DX5YG1FFDM8IkAJjnRymQlsPRnbtKanbxoDe18De1GKaLrRHPXdO
EmtUVb7fZyAKbi77mOD049zPgY1bZphJh711S7RW7haIcjAIXvMMYfSRXsTjiror
h2zkTZfjfPP6wQ95M/mYza1oNooS5iTGBTMFZeas426mqQFgPJAu6n0O0QN1hNY8
/SZKETcmdEIl4vCn7sHHgPY+J25vFSBdhQd1nMbUhMFsnA/QKvnPTT6H0PrNgWMM
mgC0zHAnSnhJFA0nUw4rpIr+JHtUb4QKhX/GQtAvf27X82x5sMuguEhGm9Wdngpc
s+B0YG+Q7xd4uhr24tOnYKiSmsvNl1fdOKnOO4eHPna9zx1HUIpyfurKytfEoIoH
+eOWl8IhbwnjVMWpODg8lzFyJJmoxjuDDuvSZnbQe4ejIf8ssw58hg1SqXjFpB2G
5z/4LszHy1Yk6Lay2oyxbBTnXK3dyY3iM9tzamW+rDwjYhNciQ7Dcb92Xtzw3Ft3
lUIbtusfRJdOAsEdZR2l
=/1It
-----END PGP SIGNATURE-----

--=-pnQvORXoma+nxB0br2qm--

