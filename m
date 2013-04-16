From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tlan: cancel work at remove path
Date: Tue, 16 Apr 2013 16:40:26 -0400 (EDT)
Message-ID: <20130416.164026.231371036648989390.davem@davemloft.net>
References: <1366111838-29841-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chessman@tux.org, netdev@vger.kernel.org, srk@ti.com, cyril@ti.com,
	vinay.hegde@ti.com
To: devendra.aaru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965211Ab3DPUk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:40:28 -0400
In-Reply-To: <1366111838-29841-1-git-send-email-devendra.aaru@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Devendra Naga <devendra.aaru@gmail.com>
Date: Tue, 16 Apr 2013 17:00:38 +0530

> the work has been scheduled from interrupt, and not been
> cancelled when the driver is unloaded, which doesn't remove
> the work item from the global workqueue. call the
> cancel_work_sync when the driver is removed (rmmod'ed).
> 
> Cc: Sriram <srk@ti.com>
> Cc: Cyril Chemparathy <cyril@ti.com>
> Cc: Vinay Hegde <vinay.hegde@ti.com>
> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>

Applied.
