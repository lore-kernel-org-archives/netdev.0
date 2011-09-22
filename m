From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/1] bna: PCI Probe Conf Lock Fix
Date: Wed, 21 Sep 2011 20:42:00 -0400 (EDT)
Message-ID: <20110921.204200.1913137093700457756.davem@davemloft.net>
References: <1316651510-19646-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
	adapter_linux_open_src_team@blc-10-4.brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205Ab1IVAnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 20:43:05 -0400
In-Reply-To: <1316651510-19646-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Wed, 21 Sep 2011 17:31:50 -0700

> If register_netdev() fails now, then we call mutex_unlock(&bnad->conf_mutex);
> on the error path, but it's already unlocked. So we acquire the lock in error
> path which will be later unlocked after the cleanup.
> 
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Applied, but I had to add:

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Please don't leave out bug reporter credit like this.
