From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: SO_TIMESTAMP implementation for TCP
Date: Fri, 30 Apr 2010 16:41:15 -0700 (PDT)
Message-ID: <20100430.164115.257514715.davem@davemloft.net>
References: <alpine.DEB.1.00.1004292246440.12776@pokey.mtv.corp.google.com>
	<20100429.233958.212393607.davem@davemloft.net>
	<i2i65634d661004300058s5ee1b177oee249d3d22baad62@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45763
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756520Ab0D3XlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 19:41:09 -0400
In-Reply-To: <i2i65634d661004300058s5ee1b177oee249d3d22baad62@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 30 Apr 2010 00:58:32 -0700

>> All these new checks and branches for a feature of questionable value.
> 
>> If you can modify you apps to grab this information you can also probe
>> for the information using external probing tools.
>>
> I don't see an nice way to do that, we're profiling a significant
> percentage of millions of connections over thousands of paths as part
> of standard operations while incurring negligible overhead.  The app
> can can easily timestamp its operations, but without some mechanism
> for getting timestamps out of a TCP connection, the networking portion
> of servicing requests is pretty much a black box in that.

If other people have an opinion about this, now would be the time
to speak up. :-)
