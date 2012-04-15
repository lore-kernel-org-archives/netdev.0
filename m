From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 2/4] ipgre: follow state of lower device
Date: Sat, 14 Apr 2012 19:56:16 -0700 (PDT)
Message-ID: <b3a68b7e-d67a-4a62-add2-3efd3f001bbf@tahiti.vyatta.com>
References: <20120414.145302.154475725141872738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35781 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756725Ab2DOC4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 22:56:17 -0400
In-Reply-To: <20120414.145302.154475725141872738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 12 Apr 2012 09:31:17 -0700
> 
> > GRE tunnels like other layered devices should propogate
> > carrier and RFC2863 state from lower device to tunnel.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Like others I don't like the ugly hash traversal.
> 
> A small hash on ifindex, iflink, or whatever ought to be easy and
> make
> the code look much nicer.
> 
> Longer term project is that a lot of this tunneling code can be
> commonized at some point.

yeah. also want to replace open coded rcu with rcu hlist.

other tunnels that are needed are gretap over ipv6, and vxvlan.
