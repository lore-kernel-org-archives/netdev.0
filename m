From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] ipv4: use separate genid for next hop
 exceptions
Date: Mon, 03 Jun 2013 00:10:08 -0700 (PDT)
Message-ID: <20130603.001008.1226532904370669292.davem@davemloft.net>
References: <20130527.233844.2081972819091665848.davem@davemloft.net>
	<1369723593-5307-1-git-send-email-timo.teras@iki.fi>
	<1369723593-5307-3-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab3FCHKJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:10:09 -0400
In-Reply-To: <1369723593-5307-3-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Tue, 28 May 2013 09:46:33 +0300

> commit 13d82bf5 (ipv4: Fix flushing of cached routing informations)
> added the support to flush learned pmtu information.
>=20
> However, using rt_genid is quite heavy as it is bumped on route
> add/change and multicast events amongst other places. These can
> happen quote often, especially if using dynamic routing protocols.
>=20
> While this is ok with routes (as they are just recreated locally),
> the pmtu information is learned from remote systems and the icmp
> notification can come with long delays. It is worthy to have separate
> genid to avoid excessive pmtu resets.
>=20
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied.
