From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [7/9][PATCH 2.6] Media mode rewrite
Date: Sun, 20 Jun 2004 00:20:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040619222034.GD3313@k3.hellgate.ch>
References: <20040615174942.GA11319@k3.hellgate.ch> <40D4AF10.50801@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D4AF10.50801@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Jun 2004 17:24:32 -0400, Jeff Garzik wrote:
> >+		/* Can be called from ISR. Evil. */
> >+		mdelay(1);
> 
> 
> Net drivers are slowly moving towards schedule_work()/queue_work() for 
> doing "slow path" stuff like chip reset or MII phy stuff.

I already have an item on my todo list to look at work queues. Glad to
hear that's where everyone's moving.

Roger
