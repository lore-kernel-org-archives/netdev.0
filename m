From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Do not leave router anycast address for /127 prefixes.
Date: Mon, 25 Jul 2011 16:16:26 -0700 (PDT)
Message-ID: <20110725.161626.2128046602038713160.davem@davemloft.net>
References: <1311543874-16901-1-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bjorn@mork.no, brian.haley@hp.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972Ab1GYXSj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 19:18:39 -0400
In-Reply-To: <1311543874-16901-1-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: yoshfuji@linux-ipv6.org
Date: Mon, 25 Jul 2011 06:44:34 +0900

> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> Original commit 2bda8a0c8af... "Disable router anycast
> address for /127 prefixes" says:
>=20
> |   No need for matching code in addrconf_leave_anycast() as it
> |   will silently ignore any attempt to leave an unknown anycast
> |   address.
>=20
> After analysis, because 1) we may add two or more prefixes on the
> same interface, or 2)user may have manually joined that anycast,
> we may hit chances to have anycast address which as if we had
> generated one by /127 prefix and we should not leave from subnet-
> router anycast address unconditionally.
>=20
> CC: Bj=F8rn Mork <bjorn@mork.no>
> CC: Brian Haley <brian.haley@hp.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
