From: Ben Greear <greearb@candelatech.com>
Subject: via-rhine & rx-buffer size
Date: Wed, 04 May 2005 17:00:09 -0700
Message-ID: <42796209.7050305@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

I've been doing some testing with the routerboard-44 4-port Via-Rhine
NIC.  When running about 10Mbps (~1kpps) of traffic in both directions on all
4 ports, I see about 1% packet drop.  I tried adjusting the buffer sizes
like this:

#define TX_RING_SIZE	32
#define TX_QUEUE_LEN	30	/* Limit ring entries actually used. */
#define RX_RING_SIZE	64


I get slightly fewer drops (maybe, .3% or so), but I was hoping for better still.

So, first:  Any reason not to increase the buffers as show above?
(Yes, I know the part about tx buffers & QoS, so if one wants to leave
that at 16, tis fine by me).

Any ideas for other tweakings that might give me better performance?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
