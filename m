From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 00/11] net: remove disable_irq() from
 ->ndo_poll_controller
Date: Tue, 09 Dec 2014 21:44:33 -0500 (EST)
Message-ID: <20141209.214433.7463087833083181.davem@davemloft.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peterz@infradead.org, tglx@linutronix.de
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbaLJCof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 21:44:35 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Adding a new spinlock to every interrupt service routine is
simply a non-starter.

You will certainly have to find a way to fix this in a way
that doesn't involve adding any new overhead to the normal
operational paths of these drivers.

Thanks.
