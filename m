From: maxer <maxer@xmission.com>
Subject: skge no workee here
Date: Sun, 06 Feb 2005 09:19:48 -0700
Message-ID: <420643A4.9010407@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jgarzik wanted me to forward this to you today.

This nic is on the mobo. sk98lin from kernel 2.6.9 works great. However:

If I go into Fedora Core's Network Device Control applet, it shows eth0 
inactive. If I try to activate it I get:
skge device eth0:1 does not seem to be present, delaying initialization.

Under Network Configuration tool trying to probe under "Bind to MAC 
address gives the result as [Errno 19] No such device.

So while the driver clearly loads, it can't find the device nor activate 
it.

What should I do to remedy this. I can bring up the device under kernel 
2.6.9, but no kernel beyond this 2.6.10 or 2.6.11-xx works.

04:00.0 Ethernet controller: Marvell Technology Group Ltd. Gigabit 
Ethernet Controller (rev 17)
       Subsystem: Intel Corp.: Unknown device 3065
       Flags: bus master, fast devsel, latency 0, IRQ 3
       Memory at ff720000 (64-bit, non-prefetchable) [size=16K]
       I/O ports at a800 [size=256]
       Expansion ROM at ff700000 [disabled] [size=128K]
       Capabilities: [48] Power Management version 2
       Capabilities: [50] Vital Product Data
       Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/1 
Enable-
       Capabilities: [e0] Express Legacy Endpoint IRQ 0
       Capabilities: [100] Advanced Error Reporting

Thanks,

RaXeT
