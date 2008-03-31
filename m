From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of netif_rx()
Date: Mon, 31 Mar 2008 08:38:22 +0200
Message-ID: <47F086DE.20306@cosmosbay.com>
References: <47E6A5FD.6060407@cosmosbay.com>	<20080328.183652.99818676.davem@davemloft.net>	<47EDFB3B.3060206@cosmosbay.com> <20080329.165415.86797572.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604003av.neufgp.fr ([84.96.92.124]:56046
	"EHLO neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752149AbYCaGic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 02:38:32 -0400
In-Reply-To: <20080329.165415.86797572.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sat, 29 Mar 2008 09:18:03 +0100
>=20
>> BTW, can loopback_xmit() be called on an interrupt stack ?
>=20
> Absolutely, softirq processes TCP data, ACK goes out in
> softirq context.

yes, ICMP messages (if any are sent) too.

>=20
> Softirqs run on interrupt stacks just as hardirqs do.
>=20

Well, it depends.

Not on x86_32 with 8K stacks, and some other arches.
do_softirq() can use the underlying stack too.

Thank you
