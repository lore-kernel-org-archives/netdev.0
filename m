From: David Miller <davem@davemloft.net>
Subject: Re: [V3 Patch 1/3] netpoll: disable netpoll when enslave a device
Date: Sun, 22 May 2011 21:03:04 -0400 (EDT)
Message-ID: <20110522.210304.407619916604454927.davem@davemloft.net>
References: <1305877152-30970-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab1EWBDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:03:07 -0400
In-Reply-To: <1305877152-30970-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 20 May 2011 15:39:10 +0800

> V3: rename NETDEV_ENSLAVE to NETDEV_JOIN
> 
> Currently we do nothing when we enslave a net device which is running netconsole.
> Neil pointed out that we may get weird results in such case, so let's disable
> netpoll on the device being enslaved. I think it is too harsh to prevent
> the device being ensalved if it is running netconsole.
> 
> By the way, this patch also removes the NETDEV_GOING_DOWN from netconsole
> netdev notifier, because netpoll will check if the device is running or not
> and we don't handle NETDEV_PRE_UP neither.
> 
> This patch is based on net-next-2.6.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@redhat.com>

Applied.
