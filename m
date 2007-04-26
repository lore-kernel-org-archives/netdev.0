From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] bridge: drop PAUSE frames
Date: Wed, 25 Apr 2007 22:07:21 -0700 (PDT)
Message-ID: <20070425.220721.48395982.davem@davemloft.net>
References: <20070425234737.727790594@linux-foundation.org>
	<20070425234950.699578312@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754451AbXDZFHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 01:07:13 -0400
In-Reply-To: <20070425234950.699578312@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 25 Apr 2007 16:47:39 -0700

> Pause frames should never make it out of the network device into
> the stack. But if a device was misconfigured, it might happen.
> So drop pause frames in bridge.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

It can happen when in promiscuous mode, but that's the only
legal case I can think of.

But that case shouldn't be hitting this path I don't think.

So this change is borderline and if anything we should put
an assertion somewhere maybe, but applied for now.

