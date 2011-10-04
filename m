From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] net: introduce ethernet teaming device
Date: Tue, 04 Oct 2011 13:51:06 -0400 (EDT)
Message-ID: <20111004.135106.65049103540781494.davem@davemloft.net>
References: <1317737703-19457-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932845Ab1JDRxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 13:53:34 -0400
In-Reply-To: <1317737703-19457-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue,  4 Oct 2011 16:15:03 +0200

> This patch introduces new network device called team. It supposes to be
> very fast, simple, userspace-driven alternative to existing bonding
> driver.
> 
> Userspace library called libteam with couple of demo apps is available
> here:
> https://github.com/jpirko/libteam
> Note it's still in its dipers atm.
> 
> team<->libteam use generic netlink for communication. That and rtnl
> suppose to be the only way to configure team device, no sysfs etc.
> 
> In near future python binding for libteam will be introduced. Also
> daemon providing arpmon/miimon active-backup functionality will
> be introduced. All what's necessary is already implemented in kernel team
> driver.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

I just want to say that, besides the implementation detail feedback you've
received thus far, I really like this stuff.  Please keep working on it!
