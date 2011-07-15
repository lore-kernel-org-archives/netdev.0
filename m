From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix panic in virtnet_remove
Date: Fri, 15 Jul 2011 08:19:09 -0700 (PDT)
Message-ID: <20110715.081909.1693878001743345571.davem@davemloft.net>
References: <20110715091650.23026.78221.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382Ab1GOPTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 11:19:14 -0400
In-Reply-To: <20110715091650.23026.78221.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Fri, 15 Jul 2011 14:46:50 +0530

> modprobe -r virtio_net panics in free_netdev() as the
> dev is already freed in the newly introduced virtnet_free
> (commit 3fa2a1df9094). Since virtnet_remove doesn't require
> dev after unregister, I am removing the free_netdev call
> in virtnet_remove instead of in virtnet_free (which seems
> to be the right place to free the dev). Confirmed that
> the panic is fixed with this patch.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

I guess the virtio NET maintainers don't deserve to get CC:'d on a fix
like this? :-(

Michael Tsirkin is who maintains this driver actively and is the one
who will merge this kind of fix to me, therefore if you don't CC:
him it might not get integrated at all.
