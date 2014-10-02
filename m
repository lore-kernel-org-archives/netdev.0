From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Thu, 2 Oct 2014 11:57:33 +0300
Message-ID: <542D137D.2090509@mellanox.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>	<1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>	<1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>	<1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>	<CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>	<1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>	<1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>	<1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>	<1412224524.16704.75.camel@edumazet-glaptop2.roam.corp.google.com>	<542D06C1.6090802@mellanox.com> <20141002102950.2b209373@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Or Gerlitz" <or.gerlitz@gmail.com>, <amira@mellanox.com>,
	<idos@mellanox.com>, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	<eyalpe@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:45819 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751266AbaJBI5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 04:57:46 -0400
In-Reply-To: <20141002102950.2b209373@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/2014 11:29 AM, Jesper Dangaard Brouer wrote:
> On Thu, 2 Oct 2014 11:03:13 +0300
> Amir Vadai <amirv@mellanox.com> wrote:
> 
>> I'm still working on it, but I can't reproduce the numbers that you
>> show. On my development machine, I get ~5.5Mpps with burst=8 and ~2Mpps
>> with burst=1.
> 
> For pktgen it sounds like you either missing:
> 
> 1) flag QUEUE_MAP_CPU

>  and/or
> 2) clone_skb $BIGNUMBER
Thanks,

This improved the numbers to ~7Mpps with burst=8 and ~4Mpps with burst=1
- still far away from 15Mpps, but in the direction.

> 
> My usage of pktgen:
>  http://netoptimizer.blogspot.dk/2014/06/pktgen-for-network-overload-testing.html
> 
