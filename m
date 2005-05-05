From: jamal <hadi@cyberus.ca>
Subject: Re: (diet-)FIB alternative fib_hlist.c
Date: Thu, 05 May 2005 08:49:29 -0400
Message-ID: <1115297370.7680.58.camel@localhost.localdomain>
References: <17016.62444.34282.625407@robur.slu.se>  <m1zmvax2cx.fsf@muc.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Jens.Laas@data.slu.se,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1zmvax2cx.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-04-05 at 20:39 +0200, Andi Kleen wrote:
> Robert Olsson <Robert.Olsson@data.slu.se> writes:
> 
> > Hello!
> >
> > fib_hlist is the smallest and simpliest routing algo we could think of
> > it's just a sorted (h)list.
> >
> > routing (FIB lookup) performance. dst hash is not used.
> >
> >     fib_hlist   fib_hash  test        routing table size 
> >     -----------------------------------------------------
> >     444 kpps    433 kpps  Single flow. local=19/main=5 entries
> >     433 kpps    431 kpps  rDoS.        local=19/main=5
> >     0.2 kpps    198 kpps  rDoS         local=19/main=123946
> >

> Great patch! I wanted to do something like this for a long time :/
> It is a good solution for 99.999% of all users who never have more
> than a few routes.
> 

Great patch it is - but why do you say "99.999% of all users" feel they
would love this? Clearly perfomance at the low routes area is not
something that is a huge difference against standard fib. And you suffer
miserably at latge route size.
Is it memory consumption you are thinking of?

cheers,
jamal
