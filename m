From: Abhinav Gupta <kernelnetworkguy@hotpop.com>
Subject: Quirky Behaviour while counting #tcp packets received.
Date: Tue, 23 Mar 2004 13:02:27 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <406097D3.10608@hotpop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am not sure if this is the correct mailing list for my question or 
not. If it isn't could someone please direct me to the correct one.

Here's what I am doing and the problem emanating from it:
I wanted to keep a track of tcp packets received from the network, so I 
started keeping a count of that by incrementing pkts_recv variable in 
the function tcp_recv_established in usr/src/linux/net/ipv4/tcp_input.c 
, everytime I receive a packet. The structure(tcp_opt) that contains 
pkts_recv variable is defined in usr/src/linux/include/net/sock.h.

The problem that I am facing is that this count(pkts_recv) increments by 
one each time I receive a tcp packet, but then something goes wrong and 
the next time it receives a packet it(pkts_recv) increments by some 
random quantity (like 36,3, 55 ...). But after this incrementation by 
the random value, the next time it receives a packet it increments by 1 
again (instead of the random value)! And there are several instances 
where the incrementation takes place by the random quantity (3-7 times 
when 1000 packets are received). I have checked in the source and the 
only place I am incrementing the count is in tcp_recv_established function.

Does anyone have views on this quirky behavior?

Any help would be greatly appreciated.

Thanks,
Abhinav.

