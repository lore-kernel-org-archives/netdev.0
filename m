From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: add a new xmit_more counter
Date: Sat, 04 Oct 2014 20:04:48 -0400 (EDT)
Message-ID: <20141004.200448.76860712037875110.davem@davemloft.net>
References: <CA+mtBx8ecpd+S+E2o8A+Hzp3i2SO7XO0+F_DYA0ng+fjta7G5A@mail.gmail.com>
	<1412262270.16704.103.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412263461.16704.107.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, brouer@redhat.com, therbert@google.com,
	netdev@vger.kernel.org, hannes@stressinduktion.org, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaJEAEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:04:51 -0400
In-Reply-To: <1412263461.16704.107.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Oct 2014 08:24:21 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> ethtool -S reports a new counter, tracking number of time doorbell
> was not triggered, because skb->xmit_more was set.
> 
> $ ethtool -S eth0 | egrep "tx_packet|xmit_more"
>      tx_packets: 2413288400
>      xmit_more: 666121277
> 
> I merged the tso_packet false sharing avoidance in this patch as well.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
