From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: correctly list all the static label mappings
Date: Thu, 07 Mar 2013 16:21:19 -0500 (EST)
Message-ID: <20130307.162119.846409617201380362.davem@davemloft.net>
References: <20130306214524.4965.59796.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758494Ab3CGVVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:21:21 -0500
In-Reply-To: <20130306214524.4965.59796.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Wed, 06 Mar 2013 16:45:24 -0500

> When we have a large number of static label mappings that spill across
> the netlink message boundary we fail to properly save our state in the
> netlink_callback struct which causes us to repeat the same listings.
> This patch fixes this problem by saving the state correctly between
> calls to the NetLabel static label netlink "dumpit" routines.
> 
> Signed-off-by: Paul Moore <pmoore@redhat.com>

Applied and queued up for -stable, thanks.

> Cc: stable@vger.kernel.org

Please just ask me to queue up networking fixes for stable, rather
than CC:'ing it to stable.

Thanks.
