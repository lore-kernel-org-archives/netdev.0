From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [net-next PATCH] etherdevice.h: random_ether_addr update
Date: Sun, 13 Sep 2009 10:03:42 +0930
Message-ID: <20090913100342.4f6a2417@opy.nosense.org>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	<20090910190703.25d14533@nehalam>
	<1252638163.4355.35.camel@Joe-Laptop.home>
	<20090911.121542.45333246.davem@davemloft.net>
	<1252700442.15292.62.camel@Joe-Laptop.home>
	<20090911141554.0072d365@nehalam>
	<1252717067.29420.22.camel@Joe-Laptop.home>
	<20090913094409.2dd88212@opy.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	donald.c.skidmore@intel.com
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adam.net.au ([202.136.110.253]:38894 "EHLO
	smtp1.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbZIMAdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Sep 2009 20:33:50 -0400
In-Reply-To: <20090913094409.2dd88212@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Sep 2009 09:44:09 +0930
Mark Smith <lk-netdev@lk-netdev.nosense.org> wrote:

> On Fri, 11 Sep 2009 17:57:47 -0700
> Joe Perches <joe@perches.com> wrote:
> 
> > On Fri, 2009-09-11 at 14:15 -0700, Stephen Hemminger wrote:
> > > On Fri, 2009-09011 at 13:20 -0700 Joe Perches wrote:
> > > > Do not use get_random_bytes to avoid drawing down entropy pool.
> > > Getting 6 bytes once is not going to be enough of a problem
> > > to drain the pool. I prefer not to weaken the randomness here.
> > 
> > I see no reason to draw down the entropy pool.
> > 
> > I have a hard time imagining that a random mac address
> > needs more than reasonably random values.
> > 
> 
> One factor to consider is the amount of effort involved in
> troubleshooting duplicate mac address problems. They don't happen
> very often, and most people won't encounter them at all. That means
> they're very low on the list of things you suspect when
> troubleshooting, so you spend a lot of time investigating other things
> first, without that time providing any value once you work out what the
> actual fault it. Once you work out what the problem is, working out
> which devices are causing it can also be an effort, as, of course, they
> now don't have unique identifiers.
> 

Hmm, probably didn't make my point all that clear. IOW, anything that
can contribute to avoiding duplicate mac addresses is worth it in my
opinion, when compared to the time (usually hours) involved in
troubleshooting duplicate mac addresses.

> 
> 
> > Why do you think it's reasonable to draw from the
> > entropy pool?
> > 
> > cheers, Joe
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
