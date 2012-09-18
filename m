From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: check for root bus in
 netxen_mask_aer_correctable
Date: Tue, 18 Sep 2012 16:23:33 -0400 (EDT)
Message-ID: <20120918.162333.687865830752588490.davem@davemloft.net>
References: <1347637803-4837-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583Ab2IRUXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 16:23:34 -0400
In-Reply-To: <1347637803-4837-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nikolay@redhat.com
Date: Fri, 14 Sep 2012 17:50:03 +0200

> From: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> Add a check if pdev->bus->self == NULL (root bus). When attaching
> a netxen NIC to a VM it can be on the root bus and the guest would
> crash in netxen_mask_aer_correctable() because of a NULL pointer
> dereference if CONFIG_PCIEAER is present.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied and queued up for -stable, thanks.
