From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to
 NOBALANCING and set affinity
Date: Fri, 23 Oct 2009 06:45:52 +0900
Message-ID: <20091023064552.6ca3cbd8@s6510>
References: <20091021022713.32449.54868.stgit@localhost.localdomain>
	<20091021.215031.57955781.davem@davemloft.net>
	<1256199756.2634.65.camel@ppwaskie-mobl2>
	<20091022.035601.193700201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, jeffrey.t.kirsher@intel.com,
	gospo@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54863 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755956AbZJVVp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2009 17:45:56 -0400
In-Reply-To: <20091022.035601.193700201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Oct 2009 03:56:01 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Date: Thu, 22 Oct 2009 01:22:36 -0700
> 
> > The first thing any performance guide says is to disable irqbalance
> 
> Such guides are wrong, and that's the end of this discussion.
> 
> These kinds of guides also say to do all kinds of crazy things with
> the socket sysctl settings.  That's wrong too and we absolutely do not
> do things to accomodate nor support those guide suggestions.
> 
> And we won't do that here.
> 
> I'm especially not going to succumb in this case because Arjan has
> been more than responsive to making sure irqbalanced in userspace does
> the right thing for networking devices, even multiqueue ones.
> 
> So we can make it do the right thing when flow director is present.
> In fact, the thing you want for flow director makes sense in the
> general case too.

irqbalance daemon already has IRQBALANCE_BANNED_INTERRUPTS
to work around this. It also has code to special case devices, if you
think ixgbe needs special treatment, why not do it there.
