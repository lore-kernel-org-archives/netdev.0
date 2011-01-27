From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Thu, 27 Jan 2011 12:15:05 -0800
Message-ID: <1296159305.1640.50.camel@localhost.localdomain>
References: <OFD293DCD2.7F0260F0-ON86257823.0061DC39-86257823.00743BB3@us.ibm.com>
	 <20110126151700.GA14113@redhat.com>
	 <1296153874.1640.27.camel@localhost.localdomain>
	 <20110127190031.GC5228@redhat.com>
	 <1296155340.1640.34.camel@localhost.localdomain>
	 <20110127193131.GD5228@redhat.com>
	 <1296157547.1640.45.camel@localhost.localdomain>
	 <20110127200548.GE5228@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steve Dobbelstein <steved@us.ibm.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:45457 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752516Ab1A0UPd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jan 2011 15:15:33 -0500
In-Reply-To: <20110127200548.GE5228@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-01-27 at 22:05 +0200, Michael S. Tsirkin wrote:
> Interesting. Could this is be a variant of the now famuous bufferbloat
> then?
> 
> I guess we could drop some packets if we see we are not keeping up.
> For
> example if we see that the ring is > X% full, we could quickly
> complete
> Y% without transmitting packets on. Or maybe we should drop some bytes
> not packets.
It's worth to try to figure out what's the best approach. I will make a
patch.


> > 
> > Requesting guest notification and extra interrupts is what we want
> to
> > avoid to reduce VM exits for saving CPUs. I don't think it's good.
> 
> Yes but how do you explain regression?
> One simple theory is that guest net stack became faster
> and so the host can't keep up.

Yes, that's what I think here. Some qdisc code has been changed
recently.

> > 
> > By polling the vq a bit more aggressively, you meant vhost, right?
> > 
> > Shirley
> 
> Yes. 

I had a similar patch before, I can modify it and test it out.

Shirley

