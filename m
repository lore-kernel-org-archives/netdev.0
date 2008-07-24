From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 14:58:11 -0700
Message-ID: <20080724145811.2d2b9ec6@extreme>
References: <200807241922.57361.opurdila@ixiacom.com>
	<20080724.132821.212118602.davem@davemloft.net>
	<200807250049.46939.opurdila@ixiacom.com>
	<20080724.145600.30988015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48686 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751864AbYGXV6N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 17:58:13 -0400
In-Reply-To: <20080724.145600.30988015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jul 2008 14:56:00 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Fri, 25 Jul 2008 00:49:46 +0300
> 
> > On Thursday 24 July 2008, David Miller wrote:
> > 
> > > Adding new fields to struct sk_buff that take up space is generally
> > > not allowed unless the new field adds substantially to the benefit of
> > > a large group of users of Linus.
> > >
> > > I don't think that applied here for this hw-tstamps stuff.
> > 
> > What about the approach proposed in the patch? Is it ok to add a pointer which 
> > may resolve other future similar issues?
> 
> Traversing the list and maintaining the reference counting and sharing
> issues is expensive and error prone.
> 
> This is what OpenBSD uses for their IPSEC state attached to MBUFs and
> it's a nightmare.
> 
> We have a timestamp in the SKB already, why don't you simply override
> it when your feature is enable and set a single flag bit that
> indicates you used a HW timestamp to set that timestamp?

How hard would it be to add PLL support to use same kind of timestamp.
Enlist the help of some NTP/clock experts to help.
