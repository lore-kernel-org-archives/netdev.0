From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xen/netback: Wake dealloc thread after completing
 zerocopy work
Date: Thu, 06 Aug 2015 23:43:42 -0700 (PDT)
Message-ID: <20150806.234342.1288177717422175509.davem@davemloft.net>
References: <1438699259-28508-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com
To: ross.lagerwall@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbbHGGnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 02:43:45 -0400
In-Reply-To: <1438699259-28508-1-git-send-email-ross.lagerwall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ross Lagerwall <ross.lagerwall@citrix.com>
Date: Tue, 4 Aug 2015 15:40:59 +0100

> Waking the dealloc thread before decrementing inflight_packets is racy
> because it means the thread may go to sleep before inflight_packets is
> decremented. If kthread_stop() has already been called, the dealloc
> thread may wait forever with nothing to wake it. Instead, wake the
> thread only after decrementing inflight_packets.
> 
> Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
> ---
> Changed in V2: Move wakeup into zerocopy_complete function.

Applied, thanks.
