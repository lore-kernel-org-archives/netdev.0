From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 2/2]: [NET_SCHED]: Making rate table lookups more flexible.
Date: Sun, 2 Sep 2007 20:56:27 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0709022006380.20071@ask.diku.dk>
References: <1188562978.18622.13.camel@localhost.localdomain>
 <46D91082.7050609@trash.net> <Pine.LNX.4.61.0709012338320.29796@ask.diku.dk>
 <46DACA48.2060602@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:44851 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbXIBS4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2007 14:56:31 -0400
In-Reply-To: <46DACA48.2060602@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2 Sep 2007, Patrick McHardy wrote:

> Jesper Dangaard Brouer wrote:
>>
>> On Sat, 1 Sep 2007, Patrick McHardy wrote:
>>
>
>> This is not a ATM/ADSL only patch.  This patch simply adds more
>> flexibility to the rate tables.  Afterwards we can start the discussion
>> about how to use this new flexibility in tc/iproute2.
>
> I know, but that discussion should happen *before* merging any
> changes to the kernel.

Let not try to solve too many things at once. We need to do this in small 
steps. Please, lets not start long and borrowing discussion again, where 
we try to solve too many things at once.


> Its pointless to add functionality that
> won't be used afterwards or may need to be done differently.

I believe that the functionality _will_ be used, also in the general case.

Lets focus on the general case, where the functionality actually is 
needed right away.

In the general case:

- The rate table needs to be aligned (cell_align=-1).
   (currently, we miscalculates up to 7 bytes on every lookup)

- The existing tc overhead calc can be made more accurate.
   (by adding overhead before doing the lookup, instead of the
    current solution where the rate table is modified with its
    limited resolution)


Patrick, note that your STAB solution will _not_ work without the rate 
table alignment.


See you!
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
