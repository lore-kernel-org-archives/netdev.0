From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: fix a potential NULL dereference
Date: Fri, 16 Sep 2011 18:56:14 -0400 (EDT)
Message-ID: <20110916.185614.1208167848704741368.davem@davemloft.net>
References: <20110902080716.GF2430@shale.localdomain>
	<CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
	<1314965963.2573.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755837Ab1IPW4S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 18:56:18 -0400
In-Reply-To: <1314965963.2573.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Sep 2011 14:19:23 +0200

> Commit bd30ce4bc0b7 (caif: Use RCU instead of spin-lock in caif_dev.c=
)
> added a potential NULL dereference in case alloc_percpu() fails.
>=20
> caif_device_alloc() can also use GFP_KERNEL instead of GFP_ATOMIC.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
