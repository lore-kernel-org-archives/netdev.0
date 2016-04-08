From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [net-next,1/2] sunrpc: do not pull udp headers on receive
Date: Fri, 8 Apr 2016 09:47:40 +0200
Message-ID: <20160408074740.GA30924@ulmo.ba.sec>
References: <1460043899-56894-2-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ikeVEW9yuYc//A+q"
Cc: netdev@vger.kernel.org, davem@davemloft.net, fcooper@ti.com,
	samanthakumar@google.com, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35806 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900AbcDHHrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 03:47:46 -0400
Received: by mail-wm0-f52.google.com with SMTP id 191so9497866wmq.0
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 00:47:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1460043899-56894-2-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 07, 2016 at 11:44:58AM -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>=20
> Commit e6afc8ace6dd modified the udp receive path by pulling the udp
> header before queuing an skbuff onto the receive queue.
>=20
> Sunrpc also calls skb_recv_datagram to dequeue an skb from a udp
> socket. Modify this receive path to also no longer expect udp
> headers.
>=20
> Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queuein=
g")
>=20
> Reported-by: Franklin S Cooper Jr. <fcooper@ti.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/sunrpc/socklib.c  | 2 +-
>  net/sunrpc/svcsock.c  | 5 ++---
>  net/sunrpc/xprtsock.c | 5 ++---
>  3 files changed, 5 insertions(+), 7 deletions(-)

Applying this and patch 2/2 (along with a couple of unrelated regulator
fixes) on top of next-20160408 fixes booting from NFS root for me on
Jetson TK1. Thanks for fixing this.

Tested-by: Thierry Reding <treding@nvidia.com>

--ikeVEW9yuYc//A+q
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJXB2IaAAoJEN0jrNd/PrOhTuwP/2Ow26KiYJA9znQcDrBqVK2+
g43I1mUaAxNGA8AK2Xu1gfLzs0Mpz7ORRAol1TrsR9FV6y9M9iUMkySC92RG6QXS
7IIq7wZAQE6XzI0SZVD6iZkRejo3wUHFRd5BrQJRN/74h5JhW7YfdxcIzrnRxmgT
wIGE0iuiybxX8lNUrhMHaEpiof0scABHG899EtjZabTO8dVr/Al7P+QrO3Iykc29
St7pB+kxixeNQShTczw+siItWcLSWVWMgjFCUXgYGw2LHCR9Cz6gkRcsdF5eiDHw
hQ+5YjKv1uJt09932tgOhJGOY9rkKkwK4UgdE8EQjlCwZ9wT8di5VK0vALb/RRsr
RIh2vRS9ldGFjAQDOIdZDk4A4SvH+wxgcNDlHgC1Jsd/JZqRSdKONTB62pUlzljm
TUqz9eovgK1+xFFSpvme7RgqGsZm0fCFaY9tjN6pdb0empirrOlXubIq4fOX+F6O
nvm5EuuytaGSRHd3WzyEuU8T9unVRXljYwUoPK2et/waG/bJBVWMZslKkBZk9k3z
+C1zlQoejmTFXonolx/2DX36rHkaSGkILWc+wJB8q67mY7PiRXSi6vShrvmIhLuX
8+kWV6LnZfRVSg9e5z6aHZTTlPOaQdx4N68KZz172DJ5Dam6zsCpcov0WUY71gUp
TxgBnkYD/bgySib1H4Dz
=6PPf
-----END PGP SIGNATURE-----

--ikeVEW9yuYc//A+q--
