From: Ethan Sommer <sommere@ethanet.com>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Tue, 20 May 2003 09:39:40 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3ECA3E2C.20805@ethanet.com>
References: <1053313298.3909.5.camel@rth.ninka.net>
 <20030519202756.I39498@shell.cyberus.ca> <3EC9B815.4000504@ethanet.com>
 <20030520080940.E40885@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
In-reply-to: <20030520080940.E40885@shell.cyberus.ca>
To: Jamal Hadi <hadi@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

Jamal Hadi wrote:

>On Tue, 20 May 2003, Ethan Sommer wrote:
>  
>
>  
>
>>Yep. We haven't spent a lot of time on optimizations. Obviously that
>>example can be fixed pretty quickly... except I'm not sure we can avoid
>>it and stay thread safe? (linux can route multiple packets at the same
>>time on an smp box right? so we can't just use a staically defined
>>buffer...)
>>
>>    
>>
>
>Your problem seesm to be the regexp scheme used. You dont need a static
>buffer i think. You should be able to operate on an incoming packet
>itself.
>
>  
>
Nope. I need to strip out all the nulls from the packet, or any posix 
regex parser will think the string ends at the first null. (so protocols 
which use null's will be difficult/impossible to identify)

I could modify the regexec function to take a length, but then it 
wouldn't be the posix regexec prototype and I was hopeing someone would 
add those to the common library of kernel functions, so others could use 
them. (and hence make it easier to maintain.)

Ethan

