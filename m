From: Ben Greear <greearb@candelatech.com>
Subject: Re: Need to build my own protocol handler...
Date: Mon, 30 Sep 2002 23:58:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D994785.3020208@candelatech.com>
References: <5.1.0.14.0.20021001085009.00b8e318@studpop.hh.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Markus Adolfsson <d98maad@stud.hh.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Markus Adolfsson wrote:
> My name is Markus Adolfsson and I'm a 25 year old master student at 
> University of Halmstad in Sweden. We are currently developing end nodes 
> in Linux that must be able to generate and receive Ethernet frames with 
> as little interference as possible from existing protocols.
> 
> We know how to solve the problem in user space by developing some sort 
> of deamon that uses PF_SOCKET and delivers incoming traffic matching a 
> certain pattern to our end node application. However, our master thesis 
> project's keyword is determinism and a latency > 5 ms is not acceptable.

You cannot guarantee low latency just by putting stuff in the kernel,
though that may help your average case.  You may get better luck by
using scheduling tricks to make your program run at a high priority.

You could even use some of the many near-realtime patches for linux.

What speeds are you looking to achieve?

Ben

> 
> Since the only way out of this requires a kernel space implementation, 
> we need to build our own protocol handler that receives and handles our 
> traffic. I've studied a couple of your articles at www.linuxjournal.com 
> but would really appreciate your guidance.
> 
> I'd like to be able to do a "Other Layer 3 Protocol Handler" as seen in 
> www.linuxjournal.com/modules/NS-lj-issues/issue95/5617f1.png but I find 
> it quite difficult to understand all of the source code in similar 
> handlers such as /net/ipv4. Which files should I look into and what are 
> the essential functions that I would have to redefine? The files are 
> quite big and some sort of map would really be nice, indicating which 
> function that calls ip_init() in net/ipv4/ip_output.c? Where would I 
> need to register my "own" protocol handler? I'm an experienced 
> programmer but I have never been hacking in the Linux kernel before...
> 
> .I realize that this probably is a quite big question that probably need 
> a rather big answer but I'm starting to get a little bit desperate and 
> any help of yours is highly appreciated;)
> 
> -- Best regards, Markus Adolfsson


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
