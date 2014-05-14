From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V8 net-next 3/6] xen-netback: Add support for multiple
 queues
Date: Wed, 14 May 2014 14:59:00 +0100
Message-ID: <20140514135859.GP6332@zion.uk.xensource.com>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
 <1400075550-4580-4-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:40457 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755590AbaENN7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 09:59:03 -0400
Content-Disposition: inline
In-Reply-To: <1400075550-4580-4-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 02:52:27PM +0100, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Builds on the refactoring of the previous patch to implement multiple
> queues between xen-netfront and xen-netback.
> 
> Writes the maximum supported number of queues into XenStore, and reads
> the values written by the frontend to determine how many queues to use.
> 
> Ring references and event channels are read from XenStore on a per-queue
> basis and rings are connected accordingly.
> 
> Also adds code to handle the cleanup of any already initialised queues
> if the initialisation of a subsequent queue fails.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
