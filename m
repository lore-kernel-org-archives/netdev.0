From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V5 net-next 1/5] xen-netback: Factor queue-specific data
 into queue struct.
Date: Fri, 28 Feb 2014 15:11:32 +0000
Message-ID: <20140228151132.GN16241@zion.uk.xensource.com>
References: <1393252387-17496-1-git-send-email-andrew.bennieston@citrix.com>
 <1393252387-17496-2-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:20503 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbaB1PLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 10:11:37 -0500
Content-Disposition: inline
In-Reply-To: <1393252387-17496-2-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 24, 2014 at 02:33:03PM +0000, Andrew J. Bennieston wrote:
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

Wei.
