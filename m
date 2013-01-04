From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac802154: fix NOHZ local_softirq_pending 08 warning
Date: Fri, 04 Jan 2013 13:47:46 -0800 (PST)
Message-ID: <20130104.134746.735863017023295302.davem@davemloft.net>
References: <1357124470-2375-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, mkl@pengutronix.de,
	netdev@vger.kernel.org, alex.aring@gmail.com
To: alex.aring@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754519Ab3ADVrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 16:47:47 -0500
In-Reply-To: <1357124470-2375-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@googlemail.com>
Date: Wed,  2 Jan 2013 12:01:10 +0100

> When using nanosleep() in an userspace application we get a
> ratelimit warning
> 
> NOHZ: local_softirq_pending 08
> 
> for 10 times.
> 
> This patch replaces netif_rx() with netif_rx_ni() which has
> to be used from process/softirq context.
> The process/softirq context will be called from fakelb driver.
> 
> See linux-kernel commit 481a819 for similar fix.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>

Applied and queued up for -stable, thanks.
