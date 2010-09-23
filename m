From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp
	reports
Date: Thu, 23 Sep 2010 11:26:03 -0600
Message-ID: <20100923172603.GM11157@obsidianresearch.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home> <20100922215052.GK11157@obsidianresearch.com> <alpine.DEB.2.00.1009231026510.32567@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Bob Arendt <rda@rincon.com>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([139.142.54.143]:56080 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755427Ab0IWR0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 13:26:13 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009231026510.32567@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 23, 2010 at 10:32:17AM -0500, Christoph Lameter wrote:

> > Is the issue you are dropping IGMP packets because the 224.0.0.2 join
> > hasn't finished? Ideally you'd wait for the SA to reply before sending
> > a IGMP, but a simpler solution might just be to use the broadcast MLID
> > for packets addressed to a MGID that has not yet got a MLID. This
> > would bebe similar to the ethernet behaviour of flooding.
> 
> IGMP reports are sent on the multicast group not on 224.0.0.2. 224.0.0.2
> is only used when leaving a multicast group.

Hm, that is quite different than in IGMPv3.. How does this work at all
in IB? A message to the multicast group isn't going to make it to any
routers unless the routers use some other means to join the IB MGID.

Jason
