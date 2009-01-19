From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH REPOST 0/5] convert arm platforms to smsc911x
Date: Mon, 19 Jan 2009 21:31:59 +0000
Message-ID: <20090119213159.GJ18301@n2100.arm.linux.org.uk>
References: <20090119092257.GB13737@n2100.arm.linux.org.uk> <OF8A57C3FE.48B3489D-ON80257543.0035BD44-80257543.003675E0@smsc.com> <20090119.131517.149029812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve.Glendinning@smsc.com, ian.saturley@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	stanley.miao@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:45999 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339AbZASVcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 16:32:21 -0500
Content-Disposition: inline
In-Reply-To: <20090119.131517.149029812.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2009 at 01:15:17PM -0800, David Miller wrote:
> From: Steve.Glendinning@smsc.com
> Date: Mon, 19 Jan 2009 09:53:54 +0000
> 
> > Russell King - ARM Linux <linux@arm.linux.org.uk> wrote on 19/01/2009 
> > 09:22:57:
> > > On Mon, Jan 19, 2009 at 04:04:34PM +0800, stanley.miao wrote:
> > > > On Sun, 2009-01-18 at 21:53 -0800, David Miller wrote:
> > > > > I've applied patches 1 and 2, the smsc911x driver changes.
> > > > > 
> > > > > I can pull the platform changes into net-next-2.6 as well
> > > > > if people don't think there will enough conflicts to cause
> > > > > problems.
> > > > 
> > > > I think  the platform data had better stay in arm tree.
> > > 
> > > What would be the impact if patches 3 to 5 got merged before 1 and 2?
> > 
> > It would not break compilation, but it would probably break ethernet 
> > support
> > on those three platforms.
> 
> That's why I suggested they go where the dependency is for
> proper functionality.

Ok, as I see it, the files with the highest chance of conflicting
in this set are the defconfig files.

Therefore, may I suggest that the defconfig updates are split from 3-5
and sent via my tree, the remainder via davem's net-next-2.6 tree?
