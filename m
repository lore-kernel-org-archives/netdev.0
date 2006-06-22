From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 16:56:01 -0400
Message-ID: <1151009762.5392.126.camel@jzny2>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
	 <20060622.015728.59653992.davem@davemloft.net>
	 <1150984380.27156.4.camel@stevo-desktop>
	 <1150990041.3040.6.camel@stevo-desktop>  <1151005381.5392.108.camel@jzny2>
	 <1151008816.3040.60.camel@stevo-desktop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:52694 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750827AbWFVU4F
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 16:56:05 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FtWDh-0001H7-5J
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 16:56:09 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1151008816.3040.60.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-22-06 at 15:40 -0500, Steve Wise wrote:
> On Thu, 2006-06-22 at 15:43 -0400, jamal wrote:
> > 
> > No - what these 2 gents are saying was these events and infrastructure
> > already exist. 
> 
> Notification of the exact events needed does not exist today.   
> 

Ok, so you cant event make use of anything that already exists?
Or is a subset of what you need already there?

> The key events, again, are:
> 
> - the neighbour entry mac address has changed.
> 
>
> - the next hop ip address (ie the neighbour) for a given dst_entry has
> changed.


I dont see a difference for the above two from an L2 perspective.
Are you keeping track of IP addresses?
You didn't answer my question in the previous email as to what RDMA
needs to keep track of in hardware.

> 
> - the path mtu for a given dst_entry has changed.
> 

Same with this.

cheers,
jamal

