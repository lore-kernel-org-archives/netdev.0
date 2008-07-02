From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] icmp: fix units for ratelimit
Date: Tue, 01 Jul 2008 19:29:16 -0700 (PDT)
Message-ID: <20080701.192916.84971699.davem@davemloft.net>
References: <20080701153820.235faa72@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35197
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758534AbYGBC3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 22:29:15 -0400
In-Reply-To: <20080701153820.235faa72@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 1 Jul 2008 15:38:20 -0700

> Convert the sysctl values for icmp ratelimit to use milliseconds instead
> of jiffies which is based on kernel configured HZ.
> Internal kernel jiffies are not a proper unit for any userspace API.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6, thanks!
