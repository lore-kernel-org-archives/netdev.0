From: Andi Kleen <ak@suse.de>
Subject: Re: Move fib_alias out of fib_hash.c
Date: Thu, 30 Sep 2004 10:08:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930080810.GB20106@wotan.suse.de>
References: <20040928214722.11aef8e0.davem@davemloft.net> <16730.53965.503605.943263@robur.slu.se> <20040929125359.12a00ba7.davem@davemloft.net> <1096492842.2344.57.camel@localhost.localdomain> <20040929142750.27b35952.davem@davemloft.net> <20040929220926.GE26714@wotan.suse.de> <415B3637.9060700@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <415B3637.9060700@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2004 at 03:24:55PM -0700, Ben Greear wrote:
> Andi Kleen wrote:
> >On Wed, Sep 29, 2004 at 02:27:50PM -0700, David S. Miller wrote:
> 
> >>Because once we add functionality to the kernel we can't simply
> >>rip it out.  People do use TOS routing, via static routes or
> >>similar.
> >
> >
> >I'm not so sure anybody uses it really. How about adding a printk for it 
> >and seeing if anybody complains? 
> 
> I don't think you should remove existing features in the middle of a stable
> release cycle.  If you want to have a compile option, that defaults to off,


There is no stable release cycle anymore. Linus has abolished that.

Maybe we will get it back at some point if the current way doesn't
work out, but currently it's unlimited hacking time.

> And I don't think the majority of people would see the printk untill way
> too late.

That was always the case, nothing new.

-Andi
