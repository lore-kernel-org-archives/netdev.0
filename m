From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1] xen-netfront: properly destroy queues when removing
 device
Date: Wed, 27 May 2015 14:03:37 -0400 (EDT)
Message-ID: <20150527.140337.2074429377294328026.davem@davemloft.net>
References: <1432737970-31872-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbbE0SDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:03:41 -0400
In-Reply-To: <1432737970-31872-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Wed, 27 May 2015 15:46:10 +0100

> xennet_remove() freed the queues before freeing the netdevice which
> results in a use-after-free when free_netdev() tries to delete the
> napi instances that have already been freed.
> 
> Fix this by fully destroy the queues (which includes deleting the napi
> instances) before freeing the netdevice.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied, thanks David.
