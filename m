From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix inet6_lookup_listener()
Date: Sat, 09 Apr 2016 16:54:24 -0400 (EDT)
Message-ID: <20160409.165424.225726402019731091.davem@davemloft.net>
References: <1460214073.6473.491.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, maze@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbcDIVHi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 17:07:38 -0400
In-Reply-To: <1460214073.6473.491.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 09 Apr 2016 08:01:13 -0700

> From: Eric Dumazet <edumazet@google.com>
>=20
> A stupid refactoring bug in inet6_lookup_listener() needs to be fixed
> in order to get proper SO_REUSEPORT behavior.
>=20
> Fixes: 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under=
 synflood")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Maciej =AFenczykowski <maze@google.com>

Applied, thanks Eric.
