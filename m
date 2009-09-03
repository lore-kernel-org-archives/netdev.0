From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 3 Sep 2009 19:30:00 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909031911400.3490@ask.diku.dk>
References: <20090902081429.GB4878@ff.dom.local> <4A9E2CC7.1010103@gmail.com>
 <alpine.DEB.1.10.0909021313160.27987@V090114053VZO-1>
 <Pine.LNX.4.64.0909031617060.28935@ask.diku.dk> <4A9FD2DC.7070807@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:34820 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751729AbZICRaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 13:30:00 -0400
In-Reply-To: <4A9FD2DC.7070807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 3 Sep 2009, Patrick McHardy wrote:

> Jesper Dangaard Brouer wrote:
>>
>> On Wed, 2 Sep 2009, Christoph Lameter wrote:
>>> On Wed, 2 Sep 2009, Eric Dumazet wrote:
>>>
>>>> Same name "eth0" is displayed, that might confuse parsers...
>>>>
>>>> What naming convention should we choose for multiqueue devices ?
>>>
>>> eth0/tx<number> ?
>>
>> Remember that we already have a naming convention in /proc/interrupts
>>
>>  eth0-tx-<number>
>>
>> Lets not introduce too many new once ;-)
>
> The approach I'm currently working on will present multiqueue root
> qdiscs as children of a dummy classful qdisc. This avoids handle
> clashes and the need for new identifiers and allows to address each
> qdisc seperately, similar to how it works with other classful qdiscs:

I like your approach. Its well suited for the qdiscs :-)

I especially like the possibility to access each qdisc seperately.  Does 
it then support having seperate qdisc per TX queue?  (I'm toying with the 
idea of transmitting our multicast traffic into/via a seperate TX hardware 
queue, and making a special qdisc for IPTV MPEG2-TS shaping)

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
