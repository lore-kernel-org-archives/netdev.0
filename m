From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] bridge: check address size
Date: Mon, 2 Nov 2009 08:54:13 -0800
Message-ID: <20091102085413.644360d5@nehalam>
References: <846C5B546E47494CBBD796CA8CA1617EA3B431@MST-VMAIL1.srv.mst.edu>
	<20091029151222.156945ca@nehalam>
	<20091029152408.6c6cc29f@nehalam>
	<20091102.000756.222203879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nneul@mst.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59287 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755908AbZKBQyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 11:54:40 -0500
In-Reply-To: <20091102.000756.222203879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 02 Nov 2009 00:07:56 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 29 Oct 2009 15:24:08 -0700
> 
> > -	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
> > +	/* Don't allow bridging non ethernet like devices */
> > +	if (dev->flags & IFF_LOOPBACK
> > +	    || dev->type != ARPHRD_ETHER
> > +	    || dev->addr_len != ETH_ALEN)
> 
> Please format this as:
> 
> > +	if (dev->flags & IFF_LOOPBACK ||
> > +	    dev->type != ARPHRD_ETHER ||
> > +	    dev->addr_len != ETH_ALEN)
> 
> What you're doing in the patch follows the GNU coding standards, no
> the kernel ones. :-)

Sure, I never saw which side to put conditionals as part of coding standard document.

-- 
