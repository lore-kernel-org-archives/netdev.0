From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [net-next-2.6 PATCH 06/13] igb: move all multicast addresses
 into multicast table array
Date: Fri, 24 Jul 2009 10:57:03 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907241053200.24126@tyr.diku.dk>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
 <20090724040853.30709.97954.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, gospo@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:44141 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750795AbZGXI5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2009 04:57:07 -0400
In-Reply-To: <20090724040853.30709.97954.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 23 Jul 2009, Jeff Kirsher wrote:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> This patch moves all of the multicast addresses out of the free Receive
> address registers and instead programs them all into the multicast table
> array.  As a result the multicast filtering may not be as precise, but it
> also greatly reduces the overhead for multicast addresses.

What do you mean by "the multicast filtering may not be as precise" ?

I'm planning to use these NICs for multicast traffic (both routing and 
monitoring).  Is there any precausing I need to be aware of?

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
