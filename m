From: Ben Greear <greearb@candelatech.com>
Subject: Re: kernel module to generate UDP & TCP traffic?
Date: Mon, 15 Apr 2002 16:52:39 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3CBB67C7.4080905@candelatech.com>
References: <Pine.LNX.4.44.0204151840060.10022-100000@havoc.ittc.ku.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Amit Kucheria <amitk@ittc.ku.edu>
List-Id: netdev.vger.kernel.org



Amit Kucheria wrote:

> On Mon, 15 Apr 2002, Ben Greear wrote:
> 
> 
>>I'm considering writing a kernel module that will be used to
>>generate and receive copious amounts of Ethernet, UDP, and TCP
>>traffic.  I would prefer to tweak/use an existing tool if any
>>is available.  Any suggestions?
>>
>>Thanks,
>>Ben
>>
> 
> 
> How about using the tun/tap devices in the 2.4. kernels which can RX/TX 
> Ethernet frames from/to userspace?


I can already send/rcv packets with raw sockets, but the problem is that
causes coppies to/from user space, which not only decreases throughput, but
adds considerable latency.  If I can run the generation down in the kernel,
it will run much faster.


> 
> http://vtun.sourceforge.net
> 
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear


