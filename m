From: Ben Greear <greearb@candelatech.com>
Subject: Re: kernel module to generate UDP & TCP traffic?
Date: Mon, 15 Apr 2002 17:25:02 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3CBB6F5E.7090502@candelatech.com>
References: <3CBB6414.5040506@candelatech.com> <20020415.164308.102569933.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org



David S. Miller wrote:

> net/core/pg3.c


It appears to be net/core/pktgen.c, but I found it :)

After reading through it a few times, I have a few questions:

It appears I can interject spacing between packets, and it also
appears that it will basically busy-spin while waiting.  So, can
I assume it would be a pretty bad idea to configure large times
between packet transmits?  (ie does the nanosleep consume the machine?)

If I wanted this thing to send a packet that would be routed,
I would just set the MAC of the router and the IP of the eventualy
destination, correct?

It appears impossible to run traffic on two interfaces simultaneously
with this module, is that true?

Would you accept a patch that turned many of these counters into 64bit
counters?

Is there any similar module that can receive these packets on the other
side and verify a correct packet was received?

Would you accept a patch that placed timestamps and sequence counters in
the packets for latency detection and packet-drop detection?


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear


