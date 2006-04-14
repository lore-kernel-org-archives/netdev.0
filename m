From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 05/10] e1000: Update truesize with the length of the
 packet for packet split
Date: Fri, 14 Apr 2006 16:52:30 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0604141650380.2116@jbrandeb-desk.amr.corp.intel.com>
References: <Pine.WNT.4.63.0604141533250.2116@jbrandeb-desk.amr.corp.intel.com>
 <20060414.155129.121789313.davem@davemloft.net>
 <Pine.WNT.4.63.0604141555200.2116@jbrandeb-desk.amr.corp.intel.com>
 <20060414.164512.17280154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jesse.brandeburg@intel.com, jgarzik@pobox.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	john.ronciak@intel.com, Jeffrey.t.kirsher@intel.com,
	auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:40601 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751284AbWDNXxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 19:53:24 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060414.164512.17280154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 14 Apr 2006, David S. Miller wrote:
> > they are not accounted for in the skb yet.  the way e1000 works is it 
> > pre-allocates all its 128 byte receive buffers using skb_alloc, and then 
> > chains in any pages that are used for receive packets.
> 
> Ok so you allocate the base skb->data memory using alloc_skb().  Then
> you add on pages and increment skb->truesize to account for the pages.
> And you do all of this for receive packets before they are passed up
> to the stack.
> 
> Right?

yes, exactly.

> If so, then that should be OK.
> 
> Jeff, I seem to have misunderstood what e1000 was doing, the patches
> changing skb->truesize should be fine.

Thanks
