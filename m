From: Ben Greear <greearb@candelatech.com>
Subject: Re: NAPI-ized tulip patch against 2.4.20-rc1
Date: Thu, 07 Nov 2002 13:25:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DCADA62.7000601@candelatech.com>
References: <Pine.GSO.4.30.0211070823590.11358-100000@shell.cyberus.ca>	<Pine.LNX.4.44.0211071013150.31376-100000@grok.yi.org> <15818.55916.259489.688198@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> greear@candelatech.com writes:
>  > On Thu, 7 Nov 2002, jamal wrote:
>  > > Trash the machines harder. Try using smaller packets;
>  > 
>  > They are already dropping packets, I thought I'd try to get a slower run 
>  > to work cleanly before trying something faster.  Precision is more
>  > important to me than absolute throughput at this point.
> 
> 
>  If you need excessive buffering this gives latency and jitter which is 
>  considered bad for network protocols and worse for test equipment.

It depends on the goals of the test, but I agree in principle :)

>  
>  > Initial run with 256 sized rx-ring (and skb-recycle) shows better
>  > performance (than with 1024 rx-ring)
>  
>  Packet size? Expect eventual effects when there is very high pressure on 
>  the packet memory system. 

Packet size has been 1514 for all my recent tests.

For an extended 256 rx-ring run (4kpps send + rcv, 1514 byte packet, 4 ports),
I see about 9k dropped packets per 55 million sent & received.

Ben

> 
>  
>  Cheers.
> 					--ro
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
