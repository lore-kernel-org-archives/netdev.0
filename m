From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 23:36:22 +0100
Message-ID: <4B0719E6.4060402@gmail.com>
References: <4B05D8DC.7020907@gmail.com> <20091120.143218.252563862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59613 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684AbZKTWgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 17:36:22 -0500
In-Reply-To: <20091120.143218.252563862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
>=20
> I like this work.  But as you know it still needs a little bit
> more work :-)
>=20
> Let's also pick a more decent name for the free function since
> tons of drivers are going to call this thing.  How about
> dev_kfree_tx_skb()? :-)
>=20
> I see Jarek and you have come to a mutual understanding about the
> locking.  Since you need to change it anyways to fix the deadlock,
> what using a netchannel like scheme to do remote SKB queueing?
>=20
> PAGE_SIZE queue arrays, lockless access to head and tail pointers, an=
d
> if queue is full we local free.
>=20
> I think that's a reasonable policy and the only detail to work out is
> to make sure we never race on the IPI send and thus miss processing
> the queue.
>=20
> What do you think?
>=20

Thats good ideas David, I'll work on them next week, and do benchmarks =
as well
before sending a new version.

Thanks
