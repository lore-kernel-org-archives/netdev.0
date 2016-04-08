From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [net-next,2/2] rxrpc: do not pull udp headers on receive
Date: Fri, 8 Apr 2016 09:48:10 +0200
Message-ID: <20160408074810.GB30924@ulmo.ba.sec>
References: <1460043899-56894-3-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="3lcZGd9BuhuYXNfi"
Cc: netdev@vger.kernel.org, davem@davemloft.net, fcooper@ti.com,
	samanthakumar@google.com, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38488 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757858AbcDHHsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 03:48:18 -0400
Received: by mail-wm0-f42.google.com with SMTP id u206so11722878wme.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 00:48:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1460043899-56894-3-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3lcZGd9BuhuYXNfi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 07, 2016 at 11:44:59AM -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>=20
> Commit e6afc8ace6dd modified the udp receive path by pulling the udp
> header before queuing an skbuff onto the receive queue.
>=20
> Rxrpc also calls skb_recv_datagram to dequeue an skb from a udp
> socket. Modify this receive path to also no longer expect udp
> headers.
>=20
> Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queuein=
g")
>=20
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/rxrpc/ar-input.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

To be explicit:

Tested-by: Thierry Reding <treding@nvidia.com>

--3lcZGd9BuhuYXNfi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJXB2I6AAoJEN0jrNd/PrOhYuAP/RkS53TPS9bkQNtt4iLlwVDy
hk7wxpLR25p8zvWvCxJ61e3+plk0jTmdX54YBtLQ7uk8uX8xMQIaQKU9tKzCwyIz
WhGeATAfQIZBq7IA9YxuFzc7yTwnXWy5Dh/mMQ3DOnk4MMTG5B98k/IDu9UM5cem
xfk/1KZCWUOgsJe+9OKnqZluYb1oN+fX6SlwyNPXMW1aX3q5qxJPoCOoHfdQZ4Wl
EtLjMGSkaaBSK9swZD5ltTetYbvzefgPFKo3RR9oKzCK4F9/5OeRululR56oJag8
+pb5Jegv0VAuT2gy7ms/YWnAoUzSQ4Z8Z3BaCI7cZBk1NrwZIg6Ey5GBeBeSefJR
lKCs/72lPHkPszKcpyMDZ+JmtvWyVXtL/H1rujK75ojnTgv+QIT+LfM2FfIl1sIy
rGZRzdcpRckjFfjl+DXzBb/OLabrbTQwOWeevOqV5lv6vfzcaOruD4UQ6MQ+lc6a
87hoMNz3wxhHK/mre0wTRk0MPQyt4RfFpZu7clhEoowHMaFbkbmcYh6sWXUCQt7s
nTkilnOaKR2MvrzwKsVV1VaBxI1Dh2Q2/qLYgVTJ/GEjUbrOEg6iFUCU86d5UZWx
zoToeMcQNL0ZY6SpszOMgvR552wb5Zyd8C4XGJL8Tx4TtAG9N3O+m0Q0dqJL3uIu
R/aAtI0+kCchxSHy037p
=Gloi
-----END PGP SIGNATURE-----

--3lcZGd9BuhuYXNfi--
