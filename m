From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Thu, 08 Oct 2009 14:13:22 +0200
Message-ID: <4ACDD762.9080101@gmail.com>
References: <4ACD9255.4020008@gmail.com> <20091008090344.GA7409@ff.dom.local> <20091008120039.GA8691@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49543 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139AbZJHMOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 08:14:03 -0400
In-Reply-To: <20091008120039.GA8691@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Thu, Oct 08, 2009 at 09:03:44AM +0000, Jarek Poplawski wrote:
> ...
>> num_tx_queues. But it seems we should rather use more often
>> real_num_tx_queue in schedulers code like dumps and maybe more
>> (like e.g. sch_multiq does).
>=20
> ...i.e. probably everywhere between dev_activate and dev_deactivate
> all qdisc operations could use real_num_tx_queues (including a test
> like: netif_is_real_multique), unless I miss something.

I am not sure David intent was being able to dynamically adjust real_nu=
m_tx_queue
between 1 and num_tx_queue.

=46or low/moderate traffic, its better to use one queue, to lower IRQ a=
ctivations,
and let some cpus sleep longer.
