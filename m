From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Fri, 8 Mar 2013 17:18:16 +0100
Message-ID: <20130308161816.GF28531@order.stressinduktion.org>
References: <20130307214211.GP7941@order.stressinduktion.org> <20130308055718.GA28531@order.stressinduktion.org> <20130308130433.GB28531@order.stressinduktion.org> <1362754386.15793.226.camel@edumazet-glaptop> <20130308150831.GD28531@order.stressinduktion.org> <1362756219.15793.240.camel@edumazet-glaptop> <20130308155404.GE28531@order.stressinduktion.org> <1362759310.15793.244.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51605 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933631Ab3CHQSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 11:18:18 -0500
Content-Disposition: inline
In-Reply-To: <1362759310.15793.244.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 08, 2013 at 08:15:10AM -0800, Eric Dumazet wrote:
> On Fri, 2013-03-08 at 16:54 +0100, Hannes Frederic Sowa wrote:
> 
> > Btw. did s.o. have a look at skb->rxhash? I just started looking after
> > its many users but perhaps someone did this job already.
> 
> You mean for IPv6 ?

Yes, because of the usage of ipv6_addr_hash in skb_flow_dissect.

> Most of us use the rxhash provided by the NIC, our software fallback is
> a best effort as well for RPS or some qdisc.
> 
> If some hacker specifically cook packets hashing to same rxhash, thats
> fine.

Ok, good to know. Thanks!
