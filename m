From: Ben Greear <greearb@candelatech.com>
Subject: 8169 driver with NetGear GA511 card.
Date: Wed, 27 Oct 2004 16:18:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41802CA8.8070900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I got one of the new GigE cardbus nics today, and it just started
working when I put it in (uses 8169 chipset evidently).  How
refreshing!

I tried stressing it, and it can handle about 30Mbps bi-directional
(1514 byte pkts).  I was hoping for better...but not too bad.

A bit later, my keyboard just stopped working.  The scratch pad
and USB mouse continued to work.  System wouldn't shut down all
the way either...forced fsck, system is back online.

The keyboard hang is reproducible...seems to happen as soon as I insert
the NIC.

Kernel is 2.6.9 + my networking patches, compiled for pentium-M
   NAPI for 8169 is enabled.

hardware is nx5000 laptop

My thanks to the 8169 driver writer(s).  I will continue to debug
this, and will be happy to try any suggestions for improving performance
and/or stability of this NIC.

Take it easy,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
