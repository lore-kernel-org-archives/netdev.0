From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] xen/netback: free already allocated memory on
 failure in xen_netbk_get_requests
Date: Wed, 06 Feb 2013 13:47:37 -0500 (EST)
Message-ID: <20130206.134737.967342633025530520.davem@davemloft.net>
References: <1360171081.32479.20.camel@zakaz.uk.xensource.com>
	<1360171098-1240-3-git-send-email-ian.campbell@citrix.com>
	<87ehgtgxhv.fsf@blp.benpfaff.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xen.org
To: blp@cs.stanford.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757915Ab3BFSrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 13:47:39 -0500
In-Reply-To: <87ehgtgxhv.fsf@blp.benpfaff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Pfaff <blp@cs.stanford.edu>
Date: Wed, 06 Feb 2013 09:31:24 -0800

> Ian Campbell <ian.campbell@citrix.com> writes:
> 
>> +	/*
>> +	 * Unwind, freeing all pages and sending error
>> +	 * reponses.
>> +	 */
> 
> s/reponses/responses/

Also please format your comments in the standard networking form
which is:

	/* Like
	 * this.
	 */

Patch #1 has the same problem, thanks Ian.
