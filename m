From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix issue while re-registering VF mgmt
 netdev
Date: Tue, 23 Aug 2016 17:08:29 -0700 (PDT)
Message-ID: <20160823.170829.2283755198663202650.davem@davemloft.net>
References: <1471932332-14150-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsioc.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55944 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753267AbcHXAJQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:09:16 -0400
In-Reply-To: <1471932332-14150-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 23 Aug 2016 11:35:32 +0530

> When we disable SRIOV, we used to unregister the netdev but wasn't
> freed. But next time when the same netdev is registered, since the state
> was in 'NETREG_UNREGISTERED', we used to hit BUG_ON in register_netdevice,
> where it expects the state to be 'NETREG_UNINITIALIZED'.
> 
> Alloc netdev and register them while configuring SRIOV, and free them
> when SRIOV is disabled. Also added a new function to setup ethernet
> properties instead of using ether_setup. Set carrier off by default,
> since we don't have to do any transmit on the interface.
> 
> Fixes: 7829451c695e ("cxgb4: Add control net_device for configuring PCIe VF")
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
