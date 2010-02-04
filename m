From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] NAPI as kobject proposal
Date: Wed, 03 Feb 2010 18:17:16 -0800 (PST)
Message-ID: <20100203.181716.29531795.davem@davemloft.net>
References: <20100129101839.36944ba5@nehalam>
	<20100203.173305.196876047.davem@davemloft.net>
	<20100203175846.545d7e56@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52326
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756072Ab0BDCRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 21:17:02 -0500
In-Reply-To: <20100203175846.545d7e56@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 3 Feb 2010 17:58:46 -0800

> The usage model I see is wanting to have:
>   1. only some cores being used for receive traffic
>      on single Rx devices (NAPI)
>   2. only some cores being used for receive traffic
>      on legacy devices (non-NAPI)
>   3. being able to configure a set of cpus with same   
>      IRQ/cache when doing Rx multi-queue.  Assign MSI-X
>      IRQ per core and allow both HT on core to split
>      that RX traffic.
> 
> All this should be manageable by some user utility like irqbalance.
> 
> #1 and #2 argue for a per device map (like irq_affinity) but
> #3 is harder; not sure the right API for that.

Do you think the people setting RPS maps aren't capable of
configuring IRQ affinities? :-)
