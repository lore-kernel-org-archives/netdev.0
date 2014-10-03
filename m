From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Fri, 03 Oct 2014 15:30:31 -0700 (PDT)
Message-ID: <20141003.153031.1190785267843072967.davem@davemloft.net>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>
	<1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412374535.17245.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468AbaJCW21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:28:27 -0400
In-Reply-To: <1412374535.17245.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Oct 2014 15:15:35 -0700

> On Fri, 2014-10-03 at 14:57 -0700, Eric Dumazet wrote:
>> On Fri, 2014-10-03 at 14:56 -0700, David Miller wrote:
>> 
>> > I completely agree, and I sort of intended this to happen when
>> > I split all the code into that new function.
>> > 
>> >   GSO segmentation of TX checksuming should not prevent other
>> > > cpus from queueing other skbs in the qdisc.
>> > > 
>> > > I will spend some time on this.
>> > 
>> > Thanks!
>> 
>> I just did my first reboot, will make sure everything is working well
>> before sending the patch ;)
> 
> This is awesome...
> 
> 40Gb rate, with TSO=on or TSO=off, it does not matter anymore.

Kick ass!
