From: Yan-Fa Li <yan@intruvert.com>
Subject: RE: TG3 Performance Question
Date: Tue, 3 Dec 2002 13:04:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <D71BEAC27500D51199DF0002B328BA8D4FBEA3@ivexs1.intruvert.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Ben Greear'" <greearb@candelatech.com>, Yan-Fa Li <yan@intruvert.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yes,

lspci:

00:08.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 Gigabit
Ethernet (rev 15)
        Subsystem: 3Com Corporation 3C996B-T 1000BaseTX
        Flags: bus master, 66Mhz, medium devsel, latency 248, IRQ 10
        Memory at f8200000 (64-bit, non-prefetchable) [size=64K]
        Capabilities: [40] PCI-X non-bridge device.
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3
Enable-

would seem to indicate that it is 66/66.  The latency is my fault, I set it
manually
to see if it would help performance.  Unfortunately I don't think the E1000
with
will with the AMD chipset, and I don't think Intel will be releasing a fix
somehow.
Do you have access to an AMD760MPX ?  I would love it if someone could
verify
this is a working combination before I go out and spend more money.

Y

-----Original Message-----
From: Ben Greear [mailto:greearb@candelatech.com] 
Sent: Tuesday, December 03, 2002 12:45 PM
To: Yan-Fa Li
Cc: netdev@oss.sgi.com
Subject: Re: TG3 Performance Question


Yan-Fa Li wrote:
> Hello
> 
> I'm trying to figure out some performance issues I have with the tg3 
> driver.

Are you sure your tg3 NIC is 66/64 PCI?  For 66/64, try an e1000 NIC, you
should be able to get 800Mbps or better out of it on such a system.

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear



[[HTML alternate version deleted]]
