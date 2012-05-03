From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/4] ipgre: follow state of lower device
Date: Thu, 3 May 2012 15:40:25 -0700
Message-ID: <20120503154025.0845359e@nehalam.linuxnetplumber.net>
References: <20120412163115.076119065@vyatta.com>
	<20120412163142.544953001@vyatta.com>
	<20120414.145302.154475725141872738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43126 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756195Ab2ECWk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 18:40:28 -0400
In-Reply-To: <20120414.145302.154475725141872738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Apr 2012 14:53:02 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

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
> A small hash on ifindex, iflink, or whatever ought to be easy and make
> the code look much nicer.
> 
> Longer term project is that a lot of this tunneling code can be
> commonized at some point.

The whole set of tunnels needs to be cleaned up to be something modular, clean
and cached like the code in OpenVswitch.
