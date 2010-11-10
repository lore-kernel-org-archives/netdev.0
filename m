From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socket
 filters
Date: Wed, 10 Nov 2010 06:53:43 +0100
Message-ID: <1289368423.2700.17.camel@edumazet-laptop>
References: <1289341724.7380.13.camel@dan>
	 <20101109.212838.193698340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: drosenberg@vsecurity.com, netdev@vger.kernel.org,
	stable@kernel.org, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55881 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751Ab0KJFxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 00:53:53 -0500
Received: by wyb36 with SMTP id 36so285919wyb.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 21:53:52 -0800 (PST)
In-Reply-To: <20101109.212838.193698340.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 21:28 -0800, David Miller a =C3=A9crit=
 :
> From: Dan Rosenberg <drosenberg@vsecurity.com>
> Date: Tue, 09 Nov 2010 17:28:44 -0500
>=20
> > The "mem" array used as scratch space for socket filters is not
> > initialized, allowing unprivileged users to leak kernel stack bytes=
=2E
> >=20
> > Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
>=20
> Prove it.

And once done, add the checks in sk_chk_filter() ?

Allow a load of mem[X] only if a prior store of mem[X] is proven.



