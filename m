From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Fri, 03 Oct 2014 14:56:47 -0700 (PDT)
Message-ID: <20141003.145647.1980640682969765484.davem@davemloft.net>
References: <20141001203345.3321.99675.stgit@dragon>
	<20141003.123806.183331913071081861.davem@davemloft.net>
	<1412369869.17245.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756845AbaJCVyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 17:54:47 -0400
In-Reply-To: <1412369869.17245.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Oct 2014 13:57:49 -0700

> On Fri, 2014-10-03 at 12:38 -0700, David Miller wrote:
>> From: Jesper Dangaard Brouer <brouer@redhat.com>
>> Date: Wed, 01 Oct 2014 22:35:31 +0200
>> 
>> > This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
>> > from the qdisc layer, to implement dequeue bulking.
>> 
>> Series applied, thanks for all of your hard work!
> 
> 
> I thinks its possible to make all validate_xmit_skb() calls outside of
> qdisc lock.

I completely agree, and I sort of intended this to happen when
I split all the code into that new function.

  GSO segmentation of TX checksuming should not prevent other
> cpus from queueing other skbs in the qdisc.
> 
> I will spend some time on this.

Thanks!
