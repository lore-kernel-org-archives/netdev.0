From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] netdev sysfs failure handling
Date: Tue, 09 May 2006 14:05:01 -0700 (PDT)
Message-ID: <20060509.140501.18000999.davem@davemloft.net>
References: <20060421134205.2786a0ee@localhost.localdomain>
	<20060506.180622.117885702.davem@davemloft.net>
	<20060509120107.0a999f38@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40865
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750900AbWEIVGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 17:06:00 -0400
To: shemminger@osdl.org
In-Reply-To: <20060509120107.0a999f38@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 9 May 2006 12:01:07 -0700

> Something like this would handle errors better, but introduce possible
> problems for drivers that call register_netdevice with irq's disabled.
> There was some comment about racing with linkwatch, but don't see how
> that could happen during creation.  
> 
> For 2.6.18?

I've been thinking about this a bit more.

How can anyone be using this with IRQ's disabled if we have
an ASSERT_RTNL() there?
