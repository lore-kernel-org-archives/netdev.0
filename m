From: Donald Becker <becker@scyld.com>
Subject: Re: via-rhine "reset did not complete" errors
Date: Mon, 28 Oct 2002 14:38:18 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210281425480.1346-100000@beohost.scyld.com>
References: <7BFCE5F1EF28D64198522688F5449D5A03C079@xchangeserver2.storigen.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org, <netdev@oss.sgi.com>, <rl@hellgate.ch>
Return-path: <netdev-bounce@oss.sgi.com>
To: Larry Sendlosky <Larry.Sendlosky@storigen.com>
In-Reply-To: <7BFCE5F1EF28D64198522688F5449D5A03C079@xchangeserver2.storigen.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Oct 2002, Larry Sendlosky wrote:

> We're using VIA EPIA mini-ITX with 800Mhz C3 and the
> VT6103 PHY. (via-rhine driver says VT6102). We have made sure
> power supply is "big enough". Our kernel is 2.4.18 with
> via-rhine.c patches to fix TX timeout.

Those are evil patches...

> Our TX timeout issues seem to have gone away with the recent
> patches. However we are still plagued with the "reset did not
> complete in 10ms" errors.

A driver _really_, _really_ shouldn't be busy-waiting for link
negotiation to complete.  That happened a lot with MS-DOS drivers, but
it wasn't even reasonable there.
Yet it's far easier for someone to get a horribly flawed patch like that
accepted, while my patches went completely ignored.


> Once it this state, a warm restart of
> the system is necessary (and we have seen this problem at
> boot time, which is more confusing).

Look at the what the code is doing.  It is easier to write drivers when
you make the rest of the kernel single threaded on your code...

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
