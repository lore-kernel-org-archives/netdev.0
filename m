From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Use sock_diag instead of procfs for new address families?
Date: Tue, 18 Jul 2017 09:58:38 -0700
Message-ID: <20170718095838.18afb608@xeon-e3>
References: <20170718161806.GA21151@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/M.oQ8MVjx1Nzn.NBJYkytWd"; protocol="application/pgp-signature"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jorgen Hansen <jhansen@vmware.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:33821 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751379AbdGRQ6m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 12:58:42 -0400
Received: by mail-pg0-f43.google.com with SMTP id 123so15919622pgj.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 09:58:41 -0700 (PDT)
In-Reply-To: <20170718161806.GA21151@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/M.oQ8MVjx1Nzn.NBJYkytWd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Jul 2017 17:18:06 +0100
Stefan Hajnoczi <stefanha@redhat.com> wrote:

> I am implementing userspace access to socket information for AF_VSOCK.
> A few hours into writing and testing a /proc/net/vsock seq_file I
> noticed that ss(8) prefers NETLINK_SOCK_DIAG over procfs.
>=20
> Before potentially wasting time implementing a legacy interface that
> won't be accepted, I thought it might be good to ask :).
>=20
> Which approach is preferred?
> 1. New address families must implement only sock_diag.
> 2. Both sock_diag and procfs must be implemented.
> 3. Implement whichever interface you prefer.
>=20
> Thanks,
> Stefan

You are correct, I am unlikely to take any new code using /proc
in ss.

--Sig_/M.oQ8MVjx1Nzn.NBJYkytWd
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEn2/DRbBb5+dmuDyPgKd/YJXN5H4FAlluPj4ACgkQgKd/YJXN
5H5GgBAAjpljHeI2moH/JZiot64wnYFplN/kxKq8JB/hZug8UyckA3/sBGA13HOH
M7eC/Km4h3mCDPrO/vMSnFOFuE++FvrDur/0WRkrsbAU8U4VQ8diqrYDhb+dasKb
BP17fUv265OdsSxS9NVXMRw6JOPnI9SYzwNjRm9Rxjl5LfVOrpjRCIfzNSXT3V/R
rzqu4sG5TvgJTgq6/gFS61pXF47msw0pnPNrc2lZyjhR+3UcpQ95Qt9Di1CT0Ey3
eQqgbrKBZbU5m/YrLtxMyxxfS9PN7XlmHmzPEBS5ktkIY6yppQF4zRzup1m4j0Xc
o5keDlM+D37vsSwbn+XLSHDxr9QB8Z7DdRwU4IctCJXUIIwNyaTBefhXaLkHKyXo
V7vAnGszPqghcmCM24FzwUh4z173xVsYuHhD+z06LOYlt4xAVZ7Jynkgg2+ayUuA
vjA8vf/9qkyhbGaQltn3ioRIlEjsLblGnjKeYExZue0JvOYP+3YduaG6SeRLbQUc
90BetEVWSIJWm/bq4Somn9qD5wJ8+c1/GrEUKb2YBpm2ebvjBoXgunXU5wN9gYsv
LRh51MlOdc1KHO+GNdripxnMOU9d9K+kHmrlYLyVZebYdXqSF3HOz7PV/tDOGgih
AJGTlil/HKZ4PgnqpPvVc+Xqz4hIbYUrr7Lh52LAGJYTjklvs2A=
=tyAK
-----END PGP SIGNATURE-----

--Sig_/M.oQ8MVjx1Nzn.NBJYkytWd--
