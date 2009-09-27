From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ax25: Fix ax25_cb refcounting in ax25_ctl_ioctl
Date: Sun, 27 Sep 2009 19:10:29 +0200
Message-ID: <20090927171029.GA3297@del.dom.local>
References: <20090921201157.GA5460@del.dom.local>
 <4ABA9058.3010605@free.fr>
 <20090925131038.GA14778@ff.dom.local>
 <20090925134052.GA1661@linux-mips.org>
 <20090925183504.GA3307@del.dom.local>
 <20090927072319.GA28089@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Bernard Pidoux <bernard.pidoux@upmc.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Ralf Baechle DL5RB <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090927072319.GA28089@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 27, 2009 at 08:23:19AM +0100, Ralf Baechle DL5RB wrote:
> On Fri, Sep 25, 2009 at 08:35:04PM +0200, Jarek Poplawski wrote:
> 
> > > > This bug isn't responsible for these oopses here, but looks quite
> > > > obviously. (I'm not sure if it's easy to test/hit with the common
> > > > tools.)
> > > 
> > > The issue your patch fixes is obvious enough.
> > 
> > Yes, with new code there would be no doubt. But here, if you know it's
> > worked for some time, you wonder if you're not blind. |-)
> 
> Most of of the ioctls are used by AX.25 userland which does error
> checking on user supplied values so userland will never attempt invalid
> ioctl calls.  So no surprise this went unnoticed.

In this case valid calls (return 0) were affected too, so I guess the
whole thing is rarely used.

Jarek P.
