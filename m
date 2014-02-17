From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH V4 net-next 3/5] xen-netfront: Factor queue-specific data
 into queue struct.
Date: Mon, 17 Feb 2014 18:04:02 +0000
Message-ID: <53024F12.4030209@citrix.com>
References: <1392659880-2538-1-git-send-email-andrew.bennieston@citrix.com> <1392659880-2538-4-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:16873 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757AbaBQSEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 13:04:05 -0500
In-Reply-To: <1392659880-2538-4-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/02/14 17:57, Andrew J. Bennieston wrote:
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

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
