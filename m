From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/3] netxen: fix lro buffer allocation
Date: Thu, 03 Sep 2009 20:33:55 -0700 (PDT)
Message-ID: <20090903.203355.227030741.davem@davemloft.net>
References: <7608421F3572AB4292BB2532AE89D565865FA8A556@AVEXMB1.qlogic.org>
	<20090903.201537.26653675.davem@davemloft.net>
	<7608421F3572AB4292BB2532AE89D565865FA8A557@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org
To: dhananjay.phadke@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35394
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753256AbZIDDdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:33:40 -0400
In-Reply-To: <7608421F3572AB4292BB2532AE89D565865FA8A557@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Date: Thu, 3 Sep 2009 20:24:15 -0700

>> But if the page allocator can't satisfy allocation requests
>> it doesn't matter how many microseconds you're saving here.
>> 
>> I think you're priorities are backwards.
> 
> Ok whatever. Whether I request 9k or 12k, page allocator
> is digging 16k chunks.
> 
> When there's enough memory, every cycle saved is important
> for firmware. I would love to enable fragmented rx, if it's
> not affecting throughput.

Ok.

Just FYI I won't be surprised if SLAB/SLUB/SLQB at some point
handle this situation differently.
