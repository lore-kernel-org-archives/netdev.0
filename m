From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH REPOST 0/5] convert arm platforms to smsc911x
Date: Mon, 19 Jan 2009 09:22:57 +0000
Message-ID: <20090119092257.GB13737@n2100.arm.linux.org.uk>
References: <1232010482-3744-1-git-send-email-steve.glendinning@smsc.com> <20090118.215321.59760406.davem@davemloft.net> <1232352274.23192.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, steve.glendinning@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	ian.saturley@smsc.com
To: "stanley.miao" <stanley.miao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:41352 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbZASJXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 04:23:18 -0500
Content-Disposition: inline
In-Reply-To: <1232352274.23192.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2009 at 04:04:34PM +0800, stanley.miao wrote:
> On Sun, 2009-01-18 at 21:53 -0800, David Miller wrote:
> > From: Steve Glendinning <steve.glendinning@smsc.com>
> > Date: Thu, 15 Jan 2009 09:07:57 +0000
> > 
> > > This patchset, intended for 2.6.30, converts all in-tree arm platforms 
> > > from smc911x to the actively maintained smsc911x driver.
> > > 
> > > I don't have any of these platforms available to me, so I've only been 
> > > able to compile-test the changes.
> > > 
> > > David Miller is planning to take the smsc911x patches via net-2.6, but 
> > > I've included them here to make testing easier as the other patches in 
> > > the set depend on them.
> > > 
> > > This patchset supercedes previous irq_flags patches from me and Stanley 
> > > Miao.
> > 
> > I've applied patches 1 and 2, the smsc911x driver changes.
> > 
> > I can pull the platform changes into net-next-2.6 as well
> > if people don't think there will enough conflicts to cause
> > problems.
> 
> I think  the platform data had better stay in arm tree.

What would be the impact if patches 3 to 5 got merged before 1 and 2?
