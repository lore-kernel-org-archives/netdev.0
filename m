From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net sched: fix race in mirred device removal
Date: Sat, 24 Jul 2010 21:04:46 -0700 (PDT)
Message-ID: <20100724.210446.115927978.davem@davemloft.net>
References: <20100722104256.5a7e7cb6@nehalam>
	<1279821733.3808.0.camel@bigi>
	<20100722214504.42e0e7de@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49251
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750818Ab0GYEEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 00:04:30 -0400
In-Reply-To: <20100722214504.42e0e7de@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 22 Jul 2010 21:45:04 -0700

> This fixes hang when target device of mirred packet classifier
> action is removed.
> 
> If a mirror or redirection action is configured to cause packets
> to go to another device, the classifier holds a ref count, but was assuming
> the adminstrator cleaned up all redirections before removing. The fix
> is to add a notifier and cleanup during unregister.
> 
> The new list is implicitly protected by RTNL mutex because
> it is held during filter add/delete as well as notifier.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied to net-2.6, thanks.
