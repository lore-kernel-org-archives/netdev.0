From: Cacophonix <cacophonix@yahoo.com>
Subject: Re: [PATCH] hp100 -- fixes for new probing.
Date: Mon, 23 Feb 2004 00:48:14 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223084814.80312.qmail@web14002.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org, jt@bougret.hpl.hp.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(resending, copying netdev) 

Hi,
Any idea if any of these patches may have broken hp100 when statically built into the 
kernel (i.e, not as a module)?

Upgrading from 2.6.0-test6 to 2.6.3-mm2 (which does include the latest patchsets for
hp100 from Stephen), the kernel locks up at boot at the point where hp100 
detection/initialization normally occurs (the driver is compiled into the kernel). 
However, changing hp100 to a module, and loading it dynamically works.

Any clues about which of the recent patches between 2.6.0-test6 and 2.6.3-mm2 might
be causing the lockup? Thanks for any pointers.

cheers,
karthik

The /proc/pci data for my hp100 nic:
  Bus  0, device  14, function  0:
    Ethernet controller: Hewlett-Packard Comp J2585B HP 10/100VG P (rev 0).
      IRQ 11.
      Master Capable.  Latency=248.  Min Gnt=8.Max Lat=32.
      I/O at 0xec00 [0xecff].
      Non-prefetchable 32 bit memory at 0xfffac000 [0xfffadfff].





__________________________________
Do you Yahoo!?
Yahoo! Mail SpamGuard - Read only the mail you want.
http://antispam.yahoo.com/tools
