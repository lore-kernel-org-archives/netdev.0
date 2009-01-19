From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST 0/5] convert arm platforms to smsc911x
Date: Mon, 19 Jan 2009 14:12:40 -0800 (PST)
Message-ID: <20090119.141240.108087992.davem@davemloft.net>
References: <OF8A57C3FE.48B3489D-ON80257543.0035BD44-80257543.003675E0@smsc.com>
	<20090119.131517.149029812.davem@davemloft.net>
	<20090119213159.GJ18301@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Steve.Glendinning@smsc.com, ian.saturley@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	stanley.miao@windriver.com
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42591
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752623AbZASWMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 17:12:39 -0500
In-Reply-To: <20090119213159.GJ18301@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Mon, 19 Jan 2009 21:31:59 +0000

> On Mon, Jan 19, 2009 at 01:15:17PM -0800, David Miller wrote:
> > From: Steve.Glendinning@smsc.com
> > Date: Mon, 19 Jan 2009 09:53:54 +0000
> > 
> > > Russell King - ARM Linux <linux@arm.linux.org.uk> wrote on 19/01/2009 
> > > 09:22:57:
> > > > On Mon, Jan 19, 2009 at 04:04:34PM +0800, stanley.miao wrote:
> > > > > On Sun, 2009-01-18 at 21:53 -0800, David Miller wrote:
> > > > > > I've applied patches 1 and 2, the smsc911x driver changes.
> > > > > > 
> > > > > > I can pull the platform changes into net-next-2.6 as well
> > > > > > if people don't think there will enough conflicts to cause
> > > > > > problems.
> > > > > 
> > > > > I think  the platform data had better stay in arm tree.
> > > > 
> > > > What would be the impact if patches 3 to 5 got merged before 1 and 2?
> > > 
> > > It would not break compilation, but it would probably break ethernet 
> > > support
> > > on those three platforms.
> > 
> > That's why I suggested they go where the dependency is for
> > proper functionality.
> 
> Ok, as I see it, the files with the highest chance of conflicting
> in this set are the defconfig files.
> 
> Therefore, may I suggest that the defconfig updates are split from 3-5
> and sent via my tree, the remainder via davem's net-next-2.6 tree?

That works for me.
