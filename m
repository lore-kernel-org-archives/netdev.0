From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix an infinite loop in tcp_slow_start()
Date: Sun, 03 Feb 2013 16:01:04 -0500 (EST)
Message-ID: <20130203.160104.248557521548380645.davem@davemloft.net>
References: <1359777110.30177.58.camel@edumazet-glaptop>
	<20130202142832.GP8912@reaktio.net>
	<1359818596.30177.84.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pasik@iki.fi, hannes@stressinduktion.org,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753614Ab3BCVBI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 16:01:08 -0500
In-Reply-To: <1359818596.30177.84.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 02 Feb 2013 07:23:16 -0800

> From: Eric Dumazet <edumazet@google.com>
>=20
> Since commit 9dc274151a548 (tcp: fix ABC in tcp_slow_start()),
> a nul snd_cwnd triggers an infinite loop in tcp_slow_start()
>=20
> Avoid this infinite loop and log a one time error for further
> analysis. FRTO code is suspected to cause this bug.
>=20
> Reported-by: Pasi K=E4rkk=E4inen <pasik@iki.fi>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
