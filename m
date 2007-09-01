From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 2/2]: [NET_SCHED]: Making rate table lookups more flexible.
Date: Sat, 1 Sep 2007 23:56:00 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0709012338320.29796@ask.diku.dk>
References: <1188562978.18622.13.camel@localhost.localdomain>
 <46D91082.7050609@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: jdb@comx.dk, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:44426 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756660AbXIAV4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Sep 2007 17:56:08 -0400
In-Reply-To: <46D91082.7050609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sat, 1 Sep 2007, Patrick McHardy wrote:

> Jesper Dangaard Brouer wrote:
>> 
>> [NET_SCHED]: Making rate table lookups more flexible.  Extend the
>> tc_ratespec struct, with two parameters: 1) "cell_align" that allow
>> adjusting the alignment of the rate table. 2) "overhead" that allow
>> adding a packet overhead before the lookup.
>
>
> Am I guessing right that the intention is to resurrect the ATM patch?

Yes, you are right.
Remember, Jamal ACKed the patch, and you redrew your NAK.

This is not a ATM/ADSL only patch.  This patch simply adds more 
flexibility to the rate tables.  Afterwards we can start the discussion 
about how to use this new flexibility in tc/iproute2.

BTW. The reason you could not measure any improvements on your SHDSL line 
is that it uses HDLC and not ATM as data link layer.

See your,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
