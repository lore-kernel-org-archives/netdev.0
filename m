From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: frto should not set snd_cwnd to 0
Date: Sun, 03 Feb 2013 16:01:13 -0500 (EST)
Message-ID: <20130203.160113.1441940891060915058.davem@davemloft.net>
References: <CADVnQykbufy-kQrEnJm0bbt=n7C8OfE1=Kr-2KfP7Mbu5Eq58w@mail.gmail.com>
	<1359826377.30177.86.camel@edumazet-glaptop>
	<1359918785.30177.111.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, ilpo.jarvinen@helsinki.fi, pasik@iki.fi,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab3BCVBP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 16:01:15 -0500
In-Reply-To: <1359918785.30177.111.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 03 Feb 2013 11:13:05 -0800

> From: Eric Dumazet <edumazet@google.com>
>=20
> Commit 9dc274151a548 (tcp: fix ABC in tcp_slow_start())
> uncovered a bug in FRTO code :
> tcp_process_frto() is setting snd_cwnd to 0 if the number
> of in flight packets is 0.
>=20
> As Neal pointed out, if no packet is in flight we lost our
> chance to disambiguate whether a loss timeout was spurious.
>=20
> We should assume it was a proper loss.
>=20
> Reported-by: Pasi K=E4rkk=E4inen <pasik@iki.fi>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
