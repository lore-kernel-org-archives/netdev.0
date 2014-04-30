From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V7 net-next 5/7] xen-netfront: Factor queue-specific data
 into queue struct.
Date: Wed, 30 Apr 2014 15:51:19 +0100
Message-ID: <20140430145119.GE19082@zion.uk.xensource.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
 <1398778035-26233-6-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:24207 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758698AbaD3OvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2014 10:51:21 -0400
Content-Disposition: inline
In-Reply-To: <1398778035-26233-6-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 02:27:13PM +0100, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> In preparation for multi-queue support in xen-netfront, move the
> queue-specific data from struct netfront_info to struct netfront_queue,
> and update the rest of the code to use this.
> 
> Also adds loops over queues where appropriate, even though only one is
> configured at this point, and uses alloc_etherdev_mq() and the
> corresponding multi-queue netif wake/start/stop functions in preparation
> for multiple active queues.
> 
> Finally, implements a trivial queue selection function suitable for
> ndo_select_queue, which simply returns 0, selecting the first (and
> only) queue.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Not an official netfront maintainer but FWIW this looks correct to me.

Acked-by: Wei Liu <wei.liu2@citrix.com>
