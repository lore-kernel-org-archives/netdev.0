From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Thu, 20 Jan 2011 22:30:36 +0100
Message-ID: <1295559036.2613.29.camel@edumazet-laptop>
References: <20110119.180418.216749267.davem@davemloft.net>
	 <AANLkTin32jUnBtHF-EAkSMnFQM6cTbn-G3NZQJ3xjTWU@mail.gmail.com>
	 <1295558748.2613.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56095 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152Ab1ATVal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 16:30:41 -0500
In-Reply-To: <1295558748.2613.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 janvier 2011 =C3=A0 22:25 +0100, Eric Dumazet a =C3=A9crit =
:

> Do you know the type of socket ? UNIX or INET ?
>=20
> You could try a revert of 2c6607c611cb7bf0a6750bcea3
> (net: add POLLPRI to sock_def_readable())
>=20
> But I dont understand how it could hurt...
>=20
>=20
>=20

Another candidate (AF_UNIX side) would be 973a34aa8593dbfe84386343c69
(af_unix: optimize unix_dgram_poll())

Thanks


