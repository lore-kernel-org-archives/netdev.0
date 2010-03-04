From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/12] IPv6: addrconf notify when address is unavailable
Date: Thu, 04 Mar 2010 00:40:06 -0800 (PST)
Message-ID: <20100304.004006.75773924.davem@davemloft.net>
References: <20100302233243.259794027@vyatta.com>
	<20100302234003.046022988@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36147
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754338Ab0CDIjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:39:47 -0500
In-Reply-To: <20100302234003.046022988@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 02 Mar 2010 15:32:46 -0800

> My recent change in net-next to retain permanent addresses caused regression.
> Device refcount would not go to zero when device was unregistered because
> left over anycast reference would hold ipv6 dev reference which would hold
> device references...
> 
> The correct procedure is to call notify chain when address is no longer
> available for use.  When interface comes back DAD timer will notify
> back that address is available.
> 
> 
> Also, link local addresses should be purged when interface is brought
> down. The address might be changed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
