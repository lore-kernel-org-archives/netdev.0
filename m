From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] Do not include linux/irq.h from linux/netpoll.h
Date: Tue, 16 Mar 2004 11:34:56 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403161133430.17272@ppc970.osdl.org>
References: <1079369568.19012.100.camel@icampbell-debian>
 <20040316001141.C29594@flint.arm.linux.org.uk> <20040316192247.A7886@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ian Campbell <icampbell@arcom.com>, netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk+lkml@arm.linux.org.uk>
In-Reply-To: <20040316192247.A7886@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 16 Mar 2004, Russell King wrote:
> > 
> > What are your thoughts on this?
> 
> So how do we solve this problem.  Should I just merge this change and
> ask you to pull it?  I think that's rather impolite though.

I didn't apply the patch because you said it was untested ;)

I'll happily remove that irq.h include if it really doesn't do anything 
but break things. I'd feel happier about it if somebody said it has been 
tested, though ;)

		Linus
