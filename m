From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH][RESEND] bonding: delete migrated IP addresses from the
 rlb hash table
Date: Wed, 28 Nov 2012 15:38:53 +0100
Message-ID: <20121128143853.GA2485@midget.suse.cz>
References: <20120620203731.GA4957@midget.suse.cz>
 <2699.1340319919@death.nxdomain>
 <20121123124419.GA3002@midget.suse.cz>
 <26343.1354064725@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, Andy Gospodarek <andy@greyhouse.net>,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48743 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755319Ab2K1Oi5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 09:38:57 -0500
Content-Disposition: inline
In-Reply-To: <26343.1354064725@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 27, 2012 at 05:05:25PM -0800, Jay Vosburgh wrote:
> Jiri Bohac <jbohac@suse.cz> wrote:

> >Were there any results of your testing?  Good or bad?
> 
> 	I did test it quite a bit (and then neglected to follow up).  I
> tried various deliberate hash collisions to try and make it fail in a
> corner case, but was unable to induce incorrect behavior.

Thanks for the review!

> 	The only issue I see is that a number of added lines run past 80
> columns, e.g.,
> 
> +		if (!(client_info->assigned && client_info->ip_src == arp->ip_src)) {
> +			/* ip_src is going to be updated, fix the src hash list */
> +			u32 hash_src = _simple_hash((u8 *)&arp->ip_src, sizeof(arp->ip_src));
> 
> +	 * sending out client updates with this IP address and the old MAC address.
> 
> +	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->used_next) {
> 
> 	... and so on. 

I'll re-send a new version with all the >80 column lines fixed.

> I did not compile and test this version, just
> applied it and inspected it; presumably it is functionally identical to
> the prior version. 

Yes, it's identical, only the comments and formatting changed.

> There's also one typo I noted near the end of the
> patch.

Fixed as well. Thanks!


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
