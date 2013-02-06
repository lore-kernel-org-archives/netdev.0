From: Ben Pfaff <blp@cs.stanford.edu>
Subject: Re: [PATCH 3/4] xen/netback: free already allocated memory on failure in xen_netbk_get_requests
Date: Wed, 06 Feb 2013 09:31:24 -0800
Message-ID: <87ehgtgxhv.fsf@blp.benpfaff.org>
References: <1360171081.32479.20.camel@zakaz.uk.xensource.com>
	<1360171098-1240-3-git-send-email-ian.campbell@citrix.com>
Reply-To: blp@cs.stanford.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-smtp-3.Stanford.EDU ([171.64.64.27]:40510 "EHLO
	cs-smtp-3.Stanford.EDU" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab3BFRbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 12:31:32 -0500
In-Reply-To: <1360171098-1240-3-git-send-email-ian.campbell@citrix.com> (Ian
	Campbell's message of "Wed, 6 Feb 2013 17:18:17 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian Campbell <ian.campbell@citrix.com> writes:

> +	/*
> +	 * Unwind, freeing all pages and sending error
> +	 * reponses.
> +	 */

s/reponses/responses/
