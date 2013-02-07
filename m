From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 3/4] xen/netback: free already allocated memory on
 failure in xen_netbk_get_requests
Date: Thu, 7 Feb 2013 09:40:08 +0000
Message-ID: <1360230008.32479.40.camel@zakaz.uk.xensource.com>
References: <1360171081.32479.20.camel@zakaz.uk.xensource.com>
	 <1360171098-1240-3-git-send-email-ian.campbell@citrix.com>
	 <87ehgtgxhv.fsf@blp.benpfaff.org>
	 <20130206.134737.967342633025530520.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "blp@cs.stanford.edu" <blp@cs.stanford.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:23558 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755820Ab3BGJkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 04:40:10 -0500
In-Reply-To: <20130206.134737.967342633025530520.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 18:47 +0000, David Miller wrote:
> From: Ben Pfaff <blp@cs.stanford.edu>
> Date: Wed, 06 Feb 2013 09:31:24 -0800
> 
> > Ian Campbell <ian.campbell@citrix.com> writes:
> > 
> >> +	/*
> >> +	 * Unwind, freeing all pages and sending error
> >> +	 * reponses.
> >> +	 */
> > 
> > s/reponses/responses/

Fixed, thanks!

> Also please format your comments in the standard networking form
> which is:
> 
> 	/* Like
> 	 * this.
> 	 */
> 
> Patch #1 has the same problem, thanks Ian.

I fixed this up, actually this particular one fits on a single line just
fine.

I'll resend shortly with the addition of the stable cc which I forgot
last time.

Thanks,
Ian.
