From: Lincoln Dale <ltd@cisco.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Wed, 12 Jun 2002 22:28:15 +1000
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae7f16$3mu$2@main.gmane.org>
References: <Message from Ben Greear <greearb@candelatech.com>
 <3D06E9A0.5060801@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: Ben Greear <greearb@candelatech.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Horst von Brand <vonbrand@inf.utfsm.cl>,
   "David S. Miller" <davem@redhat.com>
In-Reply-To: <200206121211.g5CCBjZt030139@pincoya.inf.utfsm.cl>
List-Id: netdev.vger.kernel.org

At 08:11 AM 12/06/2002 -0400, Horst von Brand wrote:
>General dislike for adding features of _extremely_ limited (debugging!) use?

i would imagine that every installation of Squid on linux is interested in 
having _realistic transaction logs_ of exactly how much data was received 
and transmitted on a TCP connection.

i know of many many folk who use transaction logs from HTTP caches for 
volume-based billing.
right now, those bills are anywhere between 10% to 25% incorrect.

you call that "extremely limited"?


of course, i am doing exactly what Dave said to do -- maintaining my own 
out-of-kernel patch -- but its a pain, i'm sure it will soon conflict with 
stuff and is a damn shame - it isn't much code, but Dave seems pretty 
steadfast that he isn't interested.

damn shame that.  i think the information is on par with 
getsockopt(..,TCP_INFO,..) in terms of usefulness yet TCP_INFO is there in 
the kernel.


cheers,

lincoln.
