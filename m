From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V8 net-next 2/6] xen-netback: Factor queue-specific data
 into queue struct.
Date: Wed, 14 May 2014 14:58:19 +0100
Message-ID: <20140514135819.GO6332@zion.uk.xensource.com>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
 <1400075550-4580-3-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26728 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbaENN6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 09:58:21 -0400
Content-Disposition: inline
In-Reply-To: <1400075550-4580-3-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 02:52:26PM +0100, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> In preparation for multi-queue support in xen-netback, move the
> queue-specific data from struct xenvif into struct xenvif_queue, and
> update the rest of the code to use this.
> 
> Also adds loops over queues where appropriate, even though only one is
> configured at this point, and uses alloc_netdev_mq() and the
> corresponding multi-queue netif wake/start/stop functions in preparation
> for multiple active queues.
> 
> Finally, implements a trivial queue selection function suitable for
> ndo_select_queue, which simply returns 0 for a single queue and uses
> skb_get_hash() to compute the queue index otherwise.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

Thanks!
Wei.
