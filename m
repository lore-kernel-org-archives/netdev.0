From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Fri, 15 Aug 2003 16:05:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815230546.GA31831@bougret.hpl.hp.com>
References: <20030815154608.56cf0551.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com,
   Martin Diehl <lists@mdiehl.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030815154608.56cf0551.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 15, 2003 at 03:46:08PM -0700, Stephen Hemminger wrote:
>
> Working on converting IRDA to new netdevice semantics,

	I hope you realised that this is most likely 2.7.X
material. There is not enough IrDA testing happening in 2.6.X to make
sure that this could work properly in the short time we have before
2.6.0. It usually take 3 months to get feedback on the 2.4.X
changes. Driver still have not caught up with the core changes in
2.6.X, so I don't feel like introducing more core changes that would
destabilise everything.
	I don't want to discourage you, because I know that this needs
to happen. Also, you may want to contact Martin Diehl, which is taking
care of irtty-sir and dongle drivers, so might have a more accurate
perpective on the problem and help on that.
	I'm not saying "No", I just want some way to reduce the risk
level. Having Martin involved is one good way.

> this is the first
> of some of the small things I found.
> 
> The irtty hashbin is created, maintained and never used.

	irtty is broken in 2.6.X, and the only thing that should
happen to it is complete removal.

> Motivation for removing is that the hashbin locking has problems with
> the locking assumptions in on network device removal.

	Please explain that, if there is a bug in hashbin, it need
fixing. I personally took care of making sure that hashbin locking is
sensible, so I have to assume that there is something wrong with
network device removal.
	Also note that the hashbin was created with NO_LOCK, so
hashbin locking can't be a problem ;-)

	Have fun...

	Jean
