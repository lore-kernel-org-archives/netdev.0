From: David Miller <davem@davemloft.net>
Subject: Re: unable to handle paging request, arm, at aio/tcp code, only 3.6
Date: Tue, 20 Nov 2012 15:18:45 -0500 (EST)
Message-ID: <20121120.151845.765619681074379121.davem@davemloft.net>
References: <20121119183222.GI2068@vicerveza.homeunix.net>
	<1353354095.10798.76.camel@edumazet-glaptop>
	<1353360858.10798.86.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: viric@viric.name, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841Ab2KTUSq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 15:18:46 -0500
In-Reply-To: <1353360858.10798.86.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Nov 2012 13:34:18 -0800

> [PATCH] ipv6: fix inet6_csk_update_pmtu() return value
>=20
> In case of error, inet6_csk_update_pmtu() should consistently
> return NULL.
>=20
> Bug added in commit 35ad9b9cf7d8a=20
> (ipv6: Add helper inet6_csk_update_pmtu().)
>=20
> Reported-by: Llu=EDs Batlle i Rossell <viric@viric.name>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

My bad.  Applied and queued up for 3.6.x-stable, thanks!
