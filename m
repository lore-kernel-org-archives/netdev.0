From: Roger Luethi <rl@hellgate.ch>
Subject: Re: via_rhine modules error on 2.6.16 with mii-tool
Date: Thu, 13 Apr 2006 23:55:58 +0200
Message-ID: <20060413215558.GA3862@k3.hellgate.ch>
References: <BAY103-F401F96F0B06D75E70AF0BFB2DF0@phx.gbl> <20060327203946.GA11824@k3.hellgate.ch> <20060413182638.GC25854@tuxdriver.com> <20060413114018.65fba555@localhost.localdomain> <20060413204731.GB2874@k3.hellgate.ch> <20060413140252.1c22b078@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail11.bluewin.ch ([195.186.18.61]:14464 "EHLO
	mail11.bluewin.ch") by vger.kernel.org with ESMTP id S964994AbWDMV45
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 17:56:57 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060413140252.1c22b078@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 14:02:52 -0700, Stephen Hemminger wrote:
> > I am not keen on patches that make via-rhine more of a special case even if
> > it was safe now; next thing you know generic_mii_ioctl is changed in a way
> > that breaks the only driver that foolishly made assumptions about the
> > side-effects of that function.
> > 
> > If you can safely move the locking down for all network drivers, that would
> > be a different story, of course.
> 
> Didn't your mother ever tell you that just because everybody else does
> it wrong, you don't have to.

No, but she warned me not to spend time on fixing botched low latency
patches.

Look, it took a lot of time to make via-rhine stable. It's still got
unexplained issues. I have a patch here for a bug that makes a driver
reload necessary when it occurs (and the patch is sitting here because
nobody's able to reproduce the problem anymore). I am lacking adequate
documentation, I have little time to work on the driver, but quite a
to do list.

Does that sound like via-rhine would make a good guinea pig?

> The other drivers should be fixed as well.  Phy access with irq's disabled
> is not good. The hardware I checked takes 100's of usecs to do one read
> transaction.

If you want to fix this in all drivers, more power to you. It is just not
high on my own priority list. I see the need for low latency, but latency
issues that only happen when people fiddle with MII settings don't seem all
that dramatic to me.

Roger
