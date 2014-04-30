From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V7 net-next 6/7] xen-netfront: Add support for multiple
 queues
Date: Wed, 30 Apr 2014 15:51:27 +0100
Message-ID: <20140430145127.GF19082@zion.uk.xensource.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
 <1398778035-26233-7-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:64609 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758698AbaD3Ov3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 10:51:29 -0400
Content-Disposition: inline
In-Reply-To: <1398778035-26233-7-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 02:27:14PM +0100, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Build on the refactoring of the previous patch to implement multiple
> queues between xen-netfront and xen-netback.
> 
> Check XenStore for multi-queue support, and set up the rings and event
> channels accordingly.
> 
> Write ring references and event channels to XenStore in a queue
> hierarchy if appropriate, or flat when using only one queue.
> 
> Update the xennet_select_queue() function to choose the queue on which
> to transmit a packet based on the skb hash result.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Not official netfront maintainer but FWIW:

Acked-by: Wei Liu <wei.liu2@citrix.com>
