From: Roland Dreier <rdreier@cisco.com>
Subject: Re: RDMA will be reverted
Date: Wed, 05 Jul 2006 13:29:35 -0700
Message-ID: <adaac7naj80.fsf@cisco.com>
References: <1151708503.11835.8.camel@trinity.ogc.int>
	<20060701.144506.74722126.davem@davemloft.net>
	<adar7119kix.fsf@cisco.com>
	<20060705.112703.71101840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@opengridcomputing.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3-in.cisco.com ([171.71.176.72]:55675 "EHLO
	sj-iport-3.cisco.com") by vger.kernel.org with ESMTP
	id S965022AbWGEU3k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 16:29:40 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060705.112703.71101840.davem@davemloft.net> (David Miller's message of "Wed, 05 Jul 2006 11:27:03 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Then why in the world would we put up explicit web pages that
 > say "TOE is bad, here's a list of reasons why" if we had any
 > intention of ever adding support for these kinds of devices?

I think there's a little bit of leap of logic there.  Everyone agrees
that winmodems are bad and yet there's still drivers/char/mwave.  This
TOE-phobia feels almost as if in the middle of one of those silly IDE
vs. SCSI flamewars, someone declared that Linux shouldn't have IDE drivers.

 > It's going to be difficult to discuss RDMA and iWARP sanely unless you
 > accept the indisputable fact that we've rejected TOE as a technology
 > entirely, and it is an example of precedence for disallowing support
 > for entire classes of hardware.

Fine.  I don't think I have much more to add to the discussion anyway.
The way forward seems to be to merge basic iWARP support that lives in
drivers/infiniband, and then you can accept or reject things for
better integration, like notifiers for routing changes.

 - R.
