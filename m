From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [PATCH] Do not include linux/irq.h from linux/netpoll.h
Date: Tue, 16 Mar 2004 19:41:21 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040316194121.C7886@flint.arm.linux.org.uk>
References: <1079369568.19012.100.camel@icampbell-debian> <20040316001141.C29594@flint.arm.linux.org.uk> <20040316192247.A7886@flint.arm.linux.org.uk> <Pine.LNX.4.58.0403161133430.17272@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Campbell <icampbell@arcom.com>, netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0403161133430.17272@ppc970.osdl.org>; from torvalds@osdl.org on Tue, Mar 16, 2004 at 11:34:56AM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 16, 2004 at 11:34:56AM -0800, Linus Torvalds wrote:
> On Tue, 16 Mar 2004, Russell King wrote:
> > > 
> > > What are your thoughts on this?
> > 
> > So how do we solve this problem.  Should I just merge this change and
> > ask you to pull it?  I think that's rather impolite though.
> 
> I didn't apply the patch because you said it was untested ;)

Ok, but bear in mind that although I can test that removing linux/irq.h
from netpoll.h fixes my problem, it really needs an x86 person to also
test it, just in case there's some dependency there that may not show
up for me.

> I'll happily remove that irq.h include if it really doesn't do anything 
> but break things. I'd feel happier about it if somebody said it has been 
> tested, though ;)

Andi Kleen, hch and jgarzik are presently discussing the issue, and I
think they're convincing themselves that linux/irq.h is disgusting
mess.

As far as me doing anything with linux/irq.h, I think that's out of my
control because ARM doesn't use it - an x86 person needs to look into
fixing it properly.

So all I can do is moan each time this problem comes up until someone
gets pissed off enough to fix it properly.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
