From: Ben Greear <greearb@candelatech.com>
Subject: Interconnect virtual device?
Date: Sun, 27 Feb 2005 21:15:30 -0800
Message-ID: <4222A8F2.6080004@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

I am considering writing a kernel module to provide a very
simple virtual interface.  This interface would be attached
to another interface, and would not be directly associated with
hardware.  It can have IP addresses & routing tables, and in
almost every way appear to be a regular ethernet interface.

The idea is that when you tx on this virtual interface, it
will cause a packet to be received on another interface.  And,
when a packet is received on the interface, it will tx on the
other interface.

I believe I can use this to create some interesting effects with
routing and bridging on a limitted number of physical interfaces.

Comments?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
