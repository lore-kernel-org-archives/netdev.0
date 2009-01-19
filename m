From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST 0/5] convert arm platforms to smsc911x
Date: Mon, 19 Jan 2009 13:15:17 -0800 (PST)
Message-ID: <20090119.131517.149029812.davem@davemloft.net>
References: <20090119092257.GB13737@n2100.arm.linux.org.uk>
	<OF8A57C3FE.48B3489D-ON80257543.0035BD44-80257543.003675E0@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, ian.saturley@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	stanley.miao@windriver.com
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49102
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752474AbZASVPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 16:15:16 -0500
In-Reply-To: <OF8A57C3FE.48B3489D-ON80257543.0035BD44-80257543.003675E0@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Mon, 19 Jan 2009 09:53:54 +0000

> Russell King - ARM Linux <linux@arm.linux.org.uk> wrote on 19/01/2009 
> 09:22:57:
> > On Mon, Jan 19, 2009 at 04:04:34PM +0800, stanley.miao wrote:
> > > On Sun, 2009-01-18 at 21:53 -0800, David Miller wrote:
> > > > I've applied patches 1 and 2, the smsc911x driver changes.
> > > > 
> > > > I can pull the platform changes into net-next-2.6 as well
> > > > if people don't think there will enough conflicts to cause
> > > > problems.
> > > 
> > > I think  the platform data had better stay in arm tree.
> > 
> > What would be the impact if patches 3 to 5 got merged before 1 and 2?
> 
> It would not break compilation, but it would probably break ethernet 
> support
> on those three platforms.

That's why I suggested they go where the dependency is for
proper functionality.
