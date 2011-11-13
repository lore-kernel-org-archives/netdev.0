From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next V8] net: introduce ethernet teaming device
Date: Sun, 13 Nov 2011 16:09:51 -0500 (EST)
Message-ID: <20111113.160951.1905657808657009542.davem@davemloft.net>
References: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com, ivecera@redhat.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab1KMVMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 16:12:16 -0500
In-Reply-To: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 12 Nov 2011 09:16:48 +0100

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
> Python binding of libteam was recently introduced.
> Daemon providing arpmon/miimon active-backup functionality will be
> introduced shortly. All what's necessary is already implemented in
> kernel team driver.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks for all of your hard work.
