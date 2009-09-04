From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/3] netxen: fix lro buffer allocation
Date: Thu, 03 Sep 2009 20:15:37 -0700 (PDT)
Message-ID: <20090903.201537.26653675.davem@davemloft.net>
References: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
	<20090903.200615.220020629.davem@davemloft.net>
	<7608421F3572AB4292BB2532AE89D565865FA8A556@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org
To: dhananjay.phadke@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58059
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932491AbZIDDPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:15:22 -0400
In-Reply-To: <7608421F3572AB4292BB2532AE89D565865FA8A556@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Date: Thu, 3 Sep 2009 20:14:01 -0700

>  
> 
>> Applied.  But allocating such huge linear buffers is asking for
>> guarenteed trouble.  Can't you split them up into page sized chunks
>> with this chip?
> 
> "chained" LRO is not enabled by firmware. Contiguous LRO requires
> fewer commands (internal) from firmware to DMA engines.

But if the page allocator can't satisfy allocation requests
it doesn't matter how many microseconds you're saving here.

I think you're priorities are backwards.
