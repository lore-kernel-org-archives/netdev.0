From: Andi Kleen <ak@muc.de>
Subject: Re: IPv4 and IPv6 stack multi-FIB, scalable in the million of
 entries.
Date: Thu, 08 Apr 2004 19:18:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3ptaiwfpq.fsf@averell.firstfloor.org>
References: <1IJuR-8qH-39@gated-at.bofh.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Mathieu Giguere" <Mathieu.Giguere@ericsson.ca>
In-Reply-To: <1IJuR-8qH-39@gated-at.bofh.it> (Mathieu Giguere's message of
 "Thu, 08 Apr 2004 17:21:01 +0200")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"Mathieu Giguere" <Mathieu.Giguere@ericsson.ca> writes:

[you should probably discuss that on netdev@oss.sgi.com instead, cc'ed]

>     We currently looking for a multi-FIB, scalable routing table in the
> million of entries, no routing cache for IPv4 and IPv6.  We want a IP stack

No routing cache? Doesn't sound like a good idea.

> that can have a log(n) (or better) insertion/deletion and lookup
> performance.  Predictable performance, even in the million of entries.

And even more vast overkill for most linux users than the existing
routing code already is.  Linux has at least the beginnings of a pluggable
FIB interface (fib_table), which has slightly bit rotted, but probably
not too bad. I would suggest you clean that up, make the existing
hash table really optional and then you can just plug in anything you want.

>     I join a patch with the fib_hash in IPv4 replace with a patricia tree
> ready for multi-FIB base on a 2.4.22 kernel.  This is the beginning of a
> long cleanup.

What do you consider dirty in the current stack? 

-Andi
