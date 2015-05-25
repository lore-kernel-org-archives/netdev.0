From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 18:44:44 -0400
Message-ID: <1432593884.32671.113.camel@jasiiieee.pacifera.com>
References: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
	 <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432579766.32671.66.camel@jasiiieee.pacifera.com>
	 <1432580733.4060.178.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432581685.32671.80.camel@jasiiieee.pacifera.com>
	 <1432586494.4060.183.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432589642.32671.108.camel@jasiiieee.pacifera.com>
	 <1432592520.32671.110.camel@jasiiieee.pacifera.com>
	 <1432593501.4060.193.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:56245 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbbEYWos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 18:44:48 -0400
In-Reply-To: <1432593501.4060.193.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 15:38 -0700, Eric Dumazet wrote:
> On Mon, 2015-05-25 at 18:22 -0400, John A. Sullivan III wrote:
> 
> > 2) Why do we still not negotiate the 16MB buffer that we get when we are
> > not using GRE?
> 
> What exact NIC handles receive side ?
> 
> If drivers allocate a full 4KB page to hold each frame,
> plus sk_buff overhead,
> then 32MB of kernel memory translates to 8MB of TCP window space.
> 
> 
> 
> 
Hi, Eric.  I'm not sure I understand the question or how to obtain the
information you've requested.  The receive side system has 48GB of RAM
but that does not sound like what you are requesting.

I suspect the behavior is a "protection mechanism", i.e., it is being
calculated for good reason.  When I set the buffer to 16MB manually in
nuttcp, performance degraded so I assume I was overrunning something.  I
am still downloading the traces.

But I'm still mystified by why this only affects GRE traffic.  Thanks -
John
