From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: don't install anycast address for /128
 addresses on routers
Date: Mon, 06 Jan 2014 16:33:16 -0500 (EST)
Message-ID: <20140106.163316.2147203775291363000.davem@davemloft.net>
References: <20140106165314.GC10204@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fx.lebail@yahoo.com, thaller@redhat.com,
	jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755453AbaAFVdS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:33:18 -0500
In-Reply-To: <20140106165314.GC10204@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 6 Jan 2014 17:53:14 +0100

> It does not make sense to create an anycast address for an /128-prefi=
x.
> Suppress it.
>=20
> As 32019e651c6fce ("ipv6: Do not leave router anycast address for /12=
7
> prefixes.") shows we also may not leave them, because we could accide=
ntally
> remove an anycast address the user has allocated or got added via ano=
ther
> prefix.
>=20
> Cc: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
> Cc: Thomas Haller <thaller@redhat.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thank you.
