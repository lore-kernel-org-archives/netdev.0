From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/2] net: init perm_addr properly and on one
 place
Date: Tue, 08 Jan 2013 18:01:06 -0800 (PST)
Message-ID: <20130108.180106.1572147969019302833.davem@davemloft.net>
References: <1357645106-1976-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	ebiederm@xmission.com, amwang@redhat.com, sassmann@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab3AICBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 21:01:08 -0500
In-Reply-To: <1357645106-1976-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  8 Jan 2013 12:38:24 +0100

> So far, it has been driver's responsibility to initialize ->perm_addr. Many
> of them does not do that though. So benefit from ->addr_assign_type existence
> and in case the type is NET_ADDR_PERM, set the ->perm_addr during dev register
> process. That allows to remove most of the driver's initializations (that what
> happen before register_netdevice() call).
> 
> Jiri Pirko (2):
>   net: init perm_addr in register_netdevice()
>   remove init of dev->perm_addr in drivers

Nice cleanup, all applied, thanks!
