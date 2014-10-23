From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 3/3] xen-netback: reintroduce guest Rx stall detection
Date: Thu, 23 Oct 2014 12:49:52 +0100
Message-ID: <20141023114952.GI9188@zion.uk.xensource.com>
References: <1413983335-8307-1-git-send-email-david.vrabel@citrix.com>
 <1413983335-8307-4-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:53991 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146AbaJWLtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 07:49:53 -0400
Content-Disposition: inline
In-Reply-To: <1413983335-8307-4-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 02:08:55PM +0100, David Vrabel wrote:
> If a frontend not receiving packets it is useful to detect this and
> turn off the carrier so packets are dropped early instead of being
> queued and drained when they expire.
> 
> A to-guest queue is stalled if it doesn't have enough free slots for a
> an extended period of time (default 60 s).
> 
> If at least one queue is stalled, the carrier is turned off (in the
> expectation that the other queues will soon stall as well).  The
> carrier is only turned on once all queues are ready.
> 
> When the frontend connects, all the queues start in the stalled state
> and only become ready once the frontend queues enough Rx requests.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>
