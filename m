From: Terry <hanfang@baidu.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 16:49:47 +0800
Message-ID: <48FD97AB.1040007@baidu.com>
References: <20081020190922.7dd6510a@extreme>	<48FD6E8A.6060304@cosmosbay.com> <18685.37380.34636.316536@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.baidu.com.163.135.61.in-addr.arpa ([61.135.163.61]:51869
	"HELO smtp.baidu.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1751605AbYJUI4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 04:56:30 -0400
In-Reply-To: <18685.37380.34636.316536@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Robert Olsson wrote:
> Eric Dumazet writes:
>  > Stephen Hemminger a =E9crit :
>  > > Add support for recycling tx buffers into receive buffers.
>  > > This is experimental at this point.
>  > >=20
>  >=20
>  > I really like this skb recycling
>
> Hi,
>
> Well the best and cleanest thing would be if the "global" recycler sl=
ab/slub=20
> was fast enough. Historically it seems like every time the link speed=
 increases=20
> (now to 10g) alloc/kfree pops up on the profiles but that challenge h=
as sofar
> been handled by slab/slub folks. Maybe we should consult them first..=
=2E
>
> Also there was some discussions to have packet objects in slab.
> =20
> Cheers.
> 					--ro
>
>
>  =20
Hi=20
    yeah. In the forwarding scenario , skb recycling should boost the=20
performance by avoiding slowpath slub alloc/free .But if  using=20
multiqueue hardware and assigning proper  cpu affinities  could  make i=
t=20
always in the fastpath of slub  alloc/free, which is faster?

Terry


