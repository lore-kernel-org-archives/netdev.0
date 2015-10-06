From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ipv4: Fix compilation errors in
 fib_rebalance
Date: Mon, 05 Oct 2015 23:48:29 -0700 (PDT)
Message-ID: <20151005.234829.1544569541989632199.davem@davemloft.net>
References: <1444109087-30676-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: pch@ordbogen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbbJFGct convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 02:32:49 -0400
In-Reply-To: <1444109087-30676-1-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Peter N=F8rlund <pch@ordbogen.com>
Date: Tue,  6 Oct 2015 07:24:47 +0200

> This fixes
>=20
> net/built-in.o: In function `fib_rebalance':
> fib_semantics.c:(.text+0x9df14): undefined reference to `__divdi3'
>=20
> and
>=20
> net/built-in.o: In function `fib_rebalance':
> net/ipv4/fib_semantics.c:572: undefined reference to `__aeabi_ldivmod=
'
>=20
> Fixes: 0e884c78ee19 ("ipv4: L3 hash-based multipath")
>=20
> Signed-off-by: Peter N=F8rlund <pch@ordbogen.com>

Applied, thanks.
