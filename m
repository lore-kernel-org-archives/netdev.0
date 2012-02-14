From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] netpoll: netpoll_poll_dev() should access dev->flags
Date: Tue, 14 Feb 2012 14:42:51 -0500 (EST)
Message-ID: <20120214.144251.1481952602061158777.davem@davemloft.net>
References: <1329217821.2336.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, nhorman@tuxdriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215Ab2BNToM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:44:12 -0500
In-Reply-To: <1329217821.2336.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Feb 2012 12:10:21 +0100

> commit 5a698af53f (bond: service netpoll arp queue on master device)
> use a dubious test : if (dev->priv_flags & IFF_SLAVE)
> 
> It seems to me IFF_SLAVE is present on dev->flags only ?
> 
> What am I missing ?

Like Neil, this looks correct to me, please submit this formally.

Thanks.
