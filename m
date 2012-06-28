From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH 1/1] xen/netback: only non-freed SKB is
 queued into tx_queue
Date: Thu, 28 Jun 2012 16:55:50 -0700 (PDT)
Message-ID: <20120628.165550.1816352825092253548.davem@davemloft.net>
References: <1340794018-17274-1-git-send-email-annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	Ian.Campbell@citrix.com, konrad.wilk@oracle.com,
	kurt.hackel@oracle.com
To: annie.li@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601Ab2F1Xzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 19:55:51 -0400
In-Reply-To: <1340794018-17274-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: annie.li@oracle.com
Date: Wed, 27 Jun 2012 18:46:58 +0800

> From: Annie Li <Annie.li@oracle.com>
> 
> After SKB is queued into tx_queue, it will be freed if request_gop is NULL.
> However, no dequeue action is called in this situation, it is likely that
> tx_queue constains freed SKB. This patch should fix this issue, and it is
> based on 3.5.0-rc4+.
> 
> This issue is found through code inspection, no bug is seen with it currently.
> I run netperf test for several hours, and no network regression was found.
> 
> Signed-off-by: Annie Li <annie.li@oracle.com>

I lack the expertiece necessary to properly review this, so I really
need a Xen expert to look this over.
