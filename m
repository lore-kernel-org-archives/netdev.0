From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Sat, 08 Jun 2002 17:13:35 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <adu71l$p8g$2@main.gmane.org>
References: <20020606.202108.52904668.davem@redhat.com>	<3D01307C.4090503@candelatech.com>	<20020608170511.B26821@mark.mielke.cc> <20020608.160407.101346167.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mark@mark.mielke.cc, cfriesen@nortelnetworks.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org



David S. Miller wrote:

> You guys we have SNMP statistics for these events, there
> is no reason to have them per-socket.  You cannot convince
> me that when you are diagnosing a problem the SNMP stats
> are not enough to show you if the packets are being dropped.


So, I will not attempt to convince you that you need per-socket
counters.  I do know for absolute certain that I would like to
have them (I write a traffic-generation & testing program).

For instance, when I run 50Mbps bi-directional on a P-4 1.6Ghz machine,
using a single port of a DFE-570tx NIC, then I drop around .2% of
the packets, in bursts.  I have kernel buffers very large (2MB),
and the CPU is not maxed out.

With the current system, it is difficult for me to know exactly what
I need to change to get better performance and/or if better performance
is even possible.


> If not, this means we need to add more SNMP events, that is
> all it means.


If you're talking per-socket SNMP counters, then that could work.
General protocol-wide counters would not help much, at least
in my case.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
