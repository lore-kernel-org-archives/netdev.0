From: Patrick McManus <mcmanus@ducksong.com>
Subject: Help Me Understand RxDescriptor Ring Size and Cache Effects
Date: Thu, 29 Apr 2004 19:36:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1083281777.13465.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I hope someone can help me better grasp the fundamentals of a
performance tuning issue.

I've got an application server that is based on a copper gigabit nic
that uses the intel e1000 driver on a pentium 4 platform. Periodically
the interface will drop a burst of packets. The default Rx Descriptor
ring size for my rev of this driver is 80, the chip supports up to 4096.
This is about 300Mbit of traffic, with a mix of packet sizes.. I suspect
the drops correspond to a burst of SYNs, not surprisingly.

Increasing the ring size gets rid of my drops starting around 256 or
so.. I also observe a pretty significant performance decrease in my
application of about 3% with the ring at its full size.. at 256 I still
see a minor performance impact, but much less than 3%.

To be clear: I'm not agitating for any kind of change, I'm just trying
to understand the principle of what is going on. I've read a few web
archives about proper sizing of rings - but they tend to be concerned
about wasting memory rather than slower performance. I presume L2 cache
effects are coming into play, but I can't articulate quite why that
would be with pci coherent buffers..

any pointers?

Thanks so much!

-Pat
