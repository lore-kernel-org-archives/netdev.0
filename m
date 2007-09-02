From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2]: [NET_SCHED]: Making rate table lookups more flexible.
Date: Sun, 02 Sep 2007 16:35:52 +0200
Message-ID: <46DACA48.2060602@trash.net>
References: <1188562978.18622.13.camel@localhost.localdomain> <46D91082.7050609@trash.net> <Pine.LNX.4.61.0709012338320.29796@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50231 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbXIBOf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 10:35:56 -0400
In-Reply-To: <Pine.LNX.4.61.0709012338320.29796@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Dangaard Brouer wrote:
> 
> On Sat, 1 Sep 2007, Patrick McHardy wrote:
> 
>> Am I guessing right that the intention is to resurrect the ATM patch?
> 
> 
> Yes, you are right.
> Remember, Jamal ACKed the patch, and you redrew your NAK.


Mainly out of frustration/boredom with the discussion, I withdrew
that again later and even Russell agreed that this should be done
differently.

> This is not a ATM/ADSL only patch.  This patch simply adds more
> flexibility to the rate tables.  Afterwards we can start the discussion
> about how to use this new flexibility in tc/iproute2.


I know, but that discussion should happen *before* merging any
changes to the kernel. Its pointless to add functionality that
won't be used afterwards or may need to be done differently.

