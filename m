From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: via-rhine unable to send back-to-back packets?
Date: Mon, 29 Nov 2004 23:27:00 +0100
Message-ID: <20041129222700.GA22918@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm running some pktgen experiments on an Nehemiah mini-ITX board which
has dual via-rhine controllers, and I'm seeing something odd -- it appears
as if either the hardware can't send back-to-back packets, or the driver
it making every packet two bytes longer than it should be.

For example, when transmitting 300-byte packets, I can TX 38261 packets
per second, but I should be able to TX ~38580.  When doing the math, it
turns out that 38261 is exactly the number of 302-byte packets you can
stuff into Fast Ethernet per second.

This test is not CPU limited -- I'm seeing the same issue from 100B
packet size up to 1500B.

Any ideas?  I had a look at the driver but found nothing odd.


cheers,
Lennert
