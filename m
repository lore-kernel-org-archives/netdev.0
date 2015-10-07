From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/5][pull request] Intel Wired LAN Driver Updates
 2015-10-03
Date: Wed, 07 Oct 2015 03:02:11 -0700 (PDT)
Message-ID: <20151007.030211.1337871252750783070.davem@davemloft.net>
References: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbbJGJq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 05:46:27 -0400
In-Reply-To: <1443927283-18456-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat,  3 Oct 2015 19:54:38 -0700

> This series contains updates to i40e and i40evf, some of which are to
> resolve more Red Hat bugzilla issues.
> 
> Jiang Liu updates the i40e and i40evf drivers to use numa_mem_id()
> instead of numa_node_id() to get the nearest node with memory which
> better supports memoryless nodes.
> 
> Anjali fixes an issue from Dan Carpenter <dan.carpenter@oracle.com>,
> to resolve a memory leak in X722 RSS configuration path, where we should
> free the memory allocated before exiting.
> 
> Shannon modifies the drivers to ensure we have the spinlocks before we
> clear the ARQ and ASQ management registers.  In addition, we widen the
> locked portion insert a sanity check to ensure we are working with safe
> register values.
> 
> Mitch fixes an issue where under certain circumstances, we can get an
> extra VF_RESOURCES message from the PF driver at runtime.  When this
> occurs, we need to parse it because our VSI may have changed and that
> will affect the relationship with the PF driver.  But this parsing also
> blows away our current MAC address, so resolve the issue by restoring
> the current MAC address from the netdev struct after we parse the
> resource message.

Series applied, thanks Jeff.
