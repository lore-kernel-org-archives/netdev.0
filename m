From: alex@pilosoft.com
Subject: kilobit=1000bit
Date: Sun, 22 Feb 2004 14:55:14 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402221447210.13023-100000@paix.pilosoft.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While trying to investigate mysterios packet loss on a link limited by tc
to its theoretical capacity, I realized that tc (and some other tools)  
treat kilobit as 1024 bits per second. This is manifestly incorrect, as it
is pretty much standard for equipment specifications to be given as 1000
bit per second=kilobit.

Examples:

* Ethernet (10BaseT)  is driven by 10Mhz (as in 10 million oscillations 
per second:) clock, resulting in 10 million bits per second capacity.

* Ethernet (100BaseT) is driven by 125Mhz clock and uses 4B/5B encoding 
resulting in 100 million bits per second capacity.

* 56k modem is (details are too long) but it results in 56000 bits/second.


I can't think of any networking technology that rates the capacity in 1024 
bits/second = kilobit.

This may be a just a heads-up to those unaware, but, it would be nice to 
change tc to use correct multipliers (possibly with a switch to revert to 
old behavior).


-alex
