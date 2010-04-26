From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: reimplement completion_queue as a FIFO queue
Date: Mon, 26 Apr 2010 00:22:40 -0700 (PDT)
Message-ID: <20100426.002240.197722540.davem@davemloft.net>
References: <1272262154.2069.1032.camel@edumazet-laptop>
	<20100425.232758.101478192.davem@davemloft.net>
	<1272266509.2346.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753717Ab0DZHWe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 03:22:34 -0400
In-Reply-To: <1272266509.2346.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 26 Apr 2010 09:21:49 +0200

> Le dimanche 25 avril 2010 =E0 23:27 -0700, David Miller a =E9crit :
>=20
>> No matter what is faster, we have to process packets in
>> FIFO order, otherwise we get reordering within a flow
>> which is to be absolutely avoided.
>=20
> Hmm, completion queue is about freeing skb, and its name is misleadin=
g.
>=20
> This queue is feed by dev_kfree_skb_irq() only

Ok I see, thanks for explaining.
