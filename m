From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCHv1 net] xen-netback: notify immediately after pushing Tx
 response.
Date: Wed, 11 Mar 2015 17:44:19 +0000
Message-ID: <20150311174419.GB15153@zion.uk.xensource.com>
References: <1426087679-13927-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59842 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbbCKRoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:44:21 -0400
Content-Disposition: inline
In-Reply-To: <1426087679-13927-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 03:27:59PM +0000, David Vrabel wrote:
> This fixes a performance regression introduced by
> 7fbb9d8415d4a51cf542e87cf3a717a9f7e6aedc (xen-netback: release pending
> index before pushing Tx responses)
> 
> Moving the notify outside of the spin locks means it can be delayed a
> long time (if the dealloc thread is descheduled or there is an
> interrupt or softirq).
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
