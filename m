From: rwhron@earthlink.net
Subject: RE: 82540EM very slow on 2.6.0-test[45]
Date: Wed, 10 Sep 2003 21:14:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911011443.GA22440@rushmore>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: scott.feldman@intel.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>> ftp'ing a multi-megabyte file gives about 16-20k/second
>> throughput.  The destination machine was running Solaris 8.

> Linux -> Solaris

Linux doing an ftp put on Solaris.

>> This is a dual boot Dell P4.  XP is about 1000x faster for
>> an ftp xfer, so the network seems okay.

> Is this Linux -> XP or XP -> Solaris?  Trying to eliminate one player.

Linux ftp put to Solaris is slow.  When booted into XP, ftp put to
Solaris is fast.  Solaris -> Solaris is fast too.

> What about Linux -> Linux?  Is that slow?

I will try that and some other combinations.  

>> dmesg shows "e1000: eth0 NIC Link is Up 100 Mbps Full Duplex". 

> This feels like a duplex mis-match.  

Could well be.  On our LAN, Solaris often has to be forced full-duplex
because auto-negotiate to the switches gives half-duplex.  The ftp server
is full duplex.  The client and server are on different segments.  

I'll check if the PC is using correct duplex/speed for it's segment.

> Are you using the same cable for the different tests?

Yes.  Same cable, same PC.  I swapped CAT5 cables, but that didn't
change throughput.

Thanks for the suggestions!

-- 
Randy Hron
http://home.earthlink.net/~rwhron/kernel/bigbox.html
