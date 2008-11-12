From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH v2] net: #ifdef inet_bind_bucket::ib_net
Date: Wed, 12 Nov 2008 11:55:29 +0100
Message-ID: <491AB621.6080202@cosmosbay.com>
References: <20081110.164424.167225199.davem@davemloft.net> <20081111110847.GC3665@x200.localdomain> <20081111111946.GD3665@x200.localdomain> <20081111.164554.143409564.davem@davemloft.net> <20081112104439.GA4292@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58369 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbYKLKze convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 05:55:34 -0500
In-Reply-To: <20081112104439.GA4292@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan a =E9crit :

> Netdevices use dev_net_set(). Add ib_net_set() and forget about this =
hungarian
> pnet thing. const qualifier is also pointless, there maybe nothing wr=
ong with
> it, be there is nothing right as well.
>=20

const qualifier is needed for upcoming cleanup patches.

Some functions in network stack do use const qualifiers, mind you.

static inline
 struct net *dev_net(const struct net_device *dev)
 {
	return read_pnet(&dev->nd_net);
 }

