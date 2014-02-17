From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH V4 net-next 4/5] xen-netfront: Add support for multiple
 queues
Date: Mon, 17 Feb 2014 18:04:40 +0000
Message-ID: <53024F38.6010205@citrix.com>
References: <1392659880-2538-1-git-send-email-andrew.bennieston@citrix.com> <1392659880-2538-5-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:17555 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815AbaBQSEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 13:04:43 -0500
In-Reply-To: <1392659880-2538-5-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/02/14 17:57, Andrew J. Bennieston wrote:
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

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
