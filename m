From: rwhron@earthlink.net
Subject: RE: 82540EM very slow on 2.6.0-test[45]
Date: Thu, 11 Sep 2003 17:06:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911210625.GA26764@rushmore>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: scott.feldman@intel.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Is this Linux -> XP or XP -> Solaris?  Trying to eliminate one player.

The destination Solaris machine has an impact.  There are two
Solaris servers on the same subnet.  For one of the servers:

Solaris ftp put to linux is fast
Solaris ftp get from linux is slow
Linux ftp put to solaris is slow
Linux ftp get from solaris is slow

For the another Solaris 8 server on the same subnet,
all ftp xfer's with Linux machine are fast.  When the
machine is booted into XP, ftp is fast to either server.

>> dmesg shows "e1000: eth0 NIC Link is Up 100 Mbps Full Duplex".

> This feels like a duplex mis-match.

The Solaris server that is slow for most Linux ftp xfers has
100 MBPs full-duplex forced.  

The Solaris server that Linux talks to fast doesn't have
any duplex/capabilities forced.

I tried 4 Solaris servers.  2 had forced full duplex
and 100 Mbps.  Those are slow.  2 other Solaris servers
on the same LAN as the "slow" Solaris servers are fast.
These "fast" servers are using default settings (which
should also be 100 Mbps full-duplex).

The odd part is that XP will talk to all four Solaris
servers fast.

-- 
Randy Hron
http://home.earthlink.net/~rwhron/kernel/bigbox.html
