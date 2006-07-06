From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: RDMA will be reverted
Date: Thu, 06 Jul 2006 00:25:03 -0500
Message-ID: <1152163503.20248.98.camel@trinity.ogc.int>
References: <adar7119kix.fsf@cisco.com>
	 <20060705.112703.71101840.davem@davemloft.net> <adaac7naj80.fsf@cisco.com>
	 <20060705.200325.74731166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:3413 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S932309AbWGFFZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 01:25:02 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060705.200325.74731166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-05 at 20:03 -0700, David Miller wrote:
> From: Roland Dreier <rdreier@cisco.com>
> Date: Wed, 05 Jul 2006 13:29:35 -0700
> 
> > The way forward seems to be to merge basic iWARP support that lives in
> > drivers/infiniband, and then you can accept or reject things for
> > better integration, like notifiers for routing changes.
> 
> <sarcasm>
> Let's merge in drivers before the necessary infrastructure.
> </sarcasm>
> 
> No, I think that's not the way forward.  You build the foundation
> before the house, if the foundation cannot be built then you are
> wasting your time with the house idea.

We have been running NFS and other apps over iWARP 24x7 for the last 6
mos...without the proposed netdev patch. We've run 200+ node MPI
clusters for days and days over iWARP...without the proposed netdev
patch. We ran iWARP interoperability tests across the country between
Boston and San Jose...without ... yes I know ... you get it.

<sarcasm>
News flash...the foundation is built!
</sarcasm>

But! Our stable LAN and the WAN tests didn't often experience MTU
changes, and redirects...but of course we knew these were inevitable. So
our goal was to make iWARP more robust in the face of a more dynamic
network topology. Shutters on the house maybe...I dunno, it's your
analogy ;-)

All that said, the proposed patch helps not only iWARP, but other
transports (iSCSI, IB) as well. It is not large, invasive,
intrusive...hell it's not even new. It leverages an existing event
notifier mechanism. 

This patch is about dotting I's and crossing T's, it's not about
foundations.


> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

