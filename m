From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [GIT] Networking
Date: Mon, 16 Aug 2010 09:53:25 +0000
Message-ID: <20100816095325.GA8547@ff.dom.local>
References: <1281883637.2942.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55293 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313Ab0HPJxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 05:53:30 -0400
Content-Disposition: inline
In-Reply-To: <1281883637.2942.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le dimanche 15 aou^t 2010 a` 12:55 +0200, Eric Dumazet a =E9crit :
=2E..
> [PATCH] netfilter: {ip,ip6,arp}_tables: avoid lockdep false positive
>=20
> After commit 24b36f019 (netfilter: {ip,ip6,arp}_tables: dont block
> bottom half more than necessary), lockdep can raise a warning
> because we attempt to lock a spinlock with BH enabled, while
> the same lock is usually locked by another cpu in a softirq context.

Btw, could you remind us how get_counters() are serialized (I guess
you can't have them on 2 cpus at the same time)?

Thanks,
Jarek P.
