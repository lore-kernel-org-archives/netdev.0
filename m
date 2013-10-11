From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: must disable bh before calling l2tp_xmit_skb()
Date: Fri, 11 Oct 2013 17:20:21 -0400 (EDT)
Message-ID: <20131011.172021.827876891266213757.davem@davemloft.net>
References: <1381316730.4971.16.camel@edumazet-glaptop.roam.corp.google.com>
	<5256592E.3080600@alphalink.fr>
	<1381411809.4971.77.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.cachereul@alphalink.fr, jchapman@katalix.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372Ab3JKVUZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 17:20:25 -0400
In-Reply-To: <1381411809.4971.77.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Oct 2013 06:30:09 -0700

> From: Eric Dumazet <edumazet@google.com>
>=20
> Fran=E7ois Cachereul made a very nice bug report and suspected
> the bh_lock_sock() / bh_unlok_sock() pair used in l2tp_xmit_skb() fro=
m
> process context was not good.
>=20
> This problem was added by commit
> ("l2tp: Fix locking in l2tp_core.c").

I added the commit SHA ID for you, please take care of this next time.

> l2tp_eth_dev_xmit() runs from BH context, so we must disable BH
> from other l2tp_xmit_skb() users.
 ...
> Reported-by: Fran=E7ois Cachereul <f.cachereul@alphalink.fr>
> Tested-by: Fran=E7ois Cachereul <f.cachereul@alphalink.fr>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks everyone.
