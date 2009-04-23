From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Software receive packet steering
Date: Thu, 23 Apr 2009 00:34:40 -0700 (PDT)
Message-ID: <20090423.003440.121254229.davem@davemloft.net>
References: <49ED967B.4070105@cosmosbay.com>
	<20090421084636.198b181e@nehalam>
	<Pine.LNX.4.62.0904221628330.10428@wlug.westbo.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dada1@cosmosbay.com, therbert@google.com,
	andi@firstfloor.org, netdev@vger.kernel.org
To: gandalf@mjufs.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54612
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757403AbZDWHer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 03:34:47 -0400
In-Reply-To: <Pine.LNX.4.62.0904221628330.10428@wlug.westbo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Josefsson <gandalf@mjufs.se>
Date: Wed, 22 Apr 2009 16:33:17 +0200 (CEST)

> On Tue, 21 Apr 2009, Stephen Hemminger wrote:
> 
>> I would like to see some way to have multiple CPU's pulling packets
>> and adapting
>> the number of CPU's being used based on load. Basically, turn all
>> device is into
>> receive multiqueue. The mapping could be adjusted by user level (see
>> irqbalancer).
> 
> I've been toying with the irqbalancer idea as well.
> Set the number of software "queues" high and have a mapping table of
> queue->cpu and then let irqbalanced which has knowledge of cpu cache
> hirarchy etc balance the load by changing the mapping table as it sees
> fit.

Steering changes without any protocol specific handling is
a total non-started because of packet reordering.

Please understand how deeply important this when considering
any packet steering scheme.  You absolutely cannot allow it
to happen.
