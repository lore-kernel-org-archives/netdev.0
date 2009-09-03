From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 3 Sep 2009 16:19:44 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909031617060.28935@ask.diku.dk>
References: <20090902081429.GB4878@ff.dom.local> <4A9E2CC7.1010103@gmail.com>
 <alpine.DEB.1.10.0909021313160.27987@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:33084 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754632AbZICOTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 10:19:43 -0400
In-Reply-To: <alpine.DEB.1.10.0909021313160.27987@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2 Sep 2009, Christoph Lameter wrote:
> On Wed, 2 Sep 2009, Eric Dumazet wrote:
>
>> Same name "eth0" is displayed, that might confuse parsers...
>>
>> What naming convention should we choose for multiqueue devices ?
>
> eth0/tx<number> ?

Remember that we already have a naming convention in /proc/interrupts

  eth0-tx-<number>

Lets not introduce too many new once ;-)

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
