From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bridge: fix locking and memory leak in br_add_bridge
Date: Mon, 05 Jun 2006 16:38:57 -0700 (PDT)
Message-ID: <20060605.163857.108741236.davem@davemloft.net>
References: <20060526110806.1fa49fe1@griffin.suse.cz>
	<20060526.192611.109883073.davem@davemloft.net>
	<20060527094528.0c330d9f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@suse.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52711
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750849AbWFEXi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 19:38:59 -0400
To: shemminger@osdl.org
In-Reply-To: <20060527094528.0c330d9f@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Sat, 27 May 2006 09:45:28 -0700

> There are several bugs in error handling in br_add_bridge:
> - when dev_alloc_name fails, allocated net_device is not freed
> - unregister_netdev is called when rtnl lock is held
> - free_netdev is called before netdev_run_todo has a chance to be run after
>   unregistering net_device
> 
> Signed-off-by: Jiri Benc <jbenc@suse.cz>
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks a lot.
