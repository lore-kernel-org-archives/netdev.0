From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Sat, 16 Aug 2003 05:20:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030816052048.5858d68a.davem@redhat.com>
References: <20030815154608.56cf0551.shemminger@osdl.org>
	<20030815230546.GA31831@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, shemminger@osdl.org,
   irda-users@lists.sourceforge.net, netdev@oss.sgi.com, lists@mdiehl.de
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20030815230546.GA31831@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Aug 2003 16:05:46 -0700
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> On Fri, Aug 15, 2003 at 03:46:08PM -0700, Stephen Hemminger wrote:
> >
> > Working on converting IRDA to new netdevice semantics,
> 
> 	I hope you realised that this is most likely 2.7.X
> material.

Without moving to the new netdevice semantics, you're
drivers will be broken.

This isn't a happy cleanup change, it is necessary.
