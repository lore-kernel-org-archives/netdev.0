From: Ben Greear <greearb@candelatech.com>
Subject: VIA Rhine (VT6105M) v/s Tulip performance.
Date: Mon, 14 Mar 2005 19:57:15 -0800
Message-ID: <42365D1B.2080504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

I just got a new 4-port VIA VT6105M NIC (router-board 44) and decided to
benchmark it against my 4-port tulip NIC (p430tx)...

My test is pktgen sending to itself across two interfaces, and my network
emulator bridging the other two interfaces.  It's wired so that pktgen is
sending a packet through the bridge.  There is no protocol overhead here
since my bridge software doesn't care, and pktgen is receiving before the
UDP protocol can get a hold of it.

Kernel is 2.4.29, P-IV 2.66Ghz, 512MB RAM, RH9 w/X and some applications
running.

With the VIA board, I get about 39Mbps tx + rx on each interface with 1514
byte packets.  I get a few dropped packets, maybe .1% or so.

The tulip board sustains about 58Mbps tx+rx on each interface, and for whatever
reason, the CPU usage is lower.  I am dropping a larger percentage of packets
with tulip, but not too bad.

Both NICs are stable under load so far...though I've only cooked them for 10 minutes
at a time.  Will let the VIA cook over-night to see if it holds up (have cooked
the tulip NICs for days and they always do well)...

The VIA board is significantly cheaper, so the lower performance may just be
the reality of the situation.  I'll try the VIA in a 2.6 kernel sometime soon
and let you all know if that changes things significantly.

Take it easy,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
