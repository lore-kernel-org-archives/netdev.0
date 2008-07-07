From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Sun, 06 Jul 2008 21:53:24 -0400
Message-ID: <48717714.9060800@garzik.org>
References: <20080706130801.6bc36cf7@infradead.org>	<20080706.155318.46569612.davem@davemloft.net>	<20080706180842.36cc0b1c@extreme> <20080706.182243.65603166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, arjan@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37075 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753684AbYGGBxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 21:53:32 -0400
In-Reply-To: <20080706.182243.65603166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Sun, 6 Jul 2008 18:08:42 -0700
> 
>> For consistency each call through ethtool_ops should
>> be holding rtnl mutex. And since dev_watchdog is a timer routine,
>> it is not safe to acquire a mutex there.
> 
> I think "get driver info", which does nothing but copy strings out of
> the driver software state, is a safe exception to these strict locking
> rules.
> 
> Don't you think? :-)

Indeed...

	Jeff



