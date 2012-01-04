From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv6: Check RA for sllao when configuring optimistic
 ipv6 address
Date: Wed, 4 Jan 2012 14:52:48 -0500
Message-ID: <20120104195248.GC24324@hmsreliant.think-freely.org>
References: <1325695643-27656-1-git-send-email-nhorman@tuxdriver.com>
 <20120104.144318.1141715284599085189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60324 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755426Ab2ADTwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 14:52:53 -0500
Content-Disposition: inline
In-Reply-To: <20120104.144318.1141715284599085189.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2012 at 02:43:18PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed,  4 Jan 2012 11:47:23 -0500
> 
> > +extern void addrconf_prefix_rcv(struct net_device *dev,
> > +				u8 *opt, int len, void *sllao);
> 
> You're not going to dereference or inspect 'sllao' otherwise you'd
> give it a more appropriate type.  You just care if it was present or
> not.
> 
> So why not just make 'sllao' a "bool" and the argument passed as the
> test "X != NULL"?
> 

Honestly I was just avoiding doing the extra comparison.  I'm happy to pass it
as a test like that though if you think its cleaner.  I'll repost shortly.

Neil
