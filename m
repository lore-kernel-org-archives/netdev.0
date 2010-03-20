From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] IPv6: convert addrconf hash list to RCU
Date: Sat, 20 Mar 2010 16:05:38 -0700 (PDT)
Message-ID: <20100320.160538.02300772.davem@davemloft.net>
References: <20100318063108.109693694@vyatta.com>
	<20100318063123.022778460@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45314
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752615Ab0CTXFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 19:05:15 -0400
In-Reply-To: <20100318063123.022778460@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Mar 2010 23:31:11 -0700

> Convert from reader/writer lock to RCU and spinlock for addrconf
> hash list.
> 
> Adds an additional helper macro for hlist_for_each_entry_continue_rcu
> to handle the continue case.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
