From: Ben Greear <greearb@candelatech.com>
Subject: Re: "Loopback" route through two cards?
Date: Thu, 12 Sep 2002 21:59:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D81709E.7040506@candelatech.com>
References: <200209031254.QAA02008@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@oss.sgi.com, anton@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> 
>>	I know this is an FAQ, but I never saw an answer I liked.
> 
> 
> And what kind of answers do you like? :-)
> 
> 
>>still impossible
> 
> 
> It depends on sense which you put to "impossible".
> 
> There are two problems with this:
> 
> 1. You cannot send to local address via any device but loopback.
> 
>    The only way to override this is to use explicit SO_BINDTODEVICE
>    on sending socket. Hence, it is "impossible" not changing application. 

Ooooh, this looks like what I'm looking for...

> 
> 2. You cannot receive packets with local address from any device
>    but loopback.
> 
>    This is impossible, but wthis time without not editing kernel,
>    removing the check for local addresses in fib_validate_source().

Any clues to which part of this method needs to be changed?  I see nothing
obviously about checking for local IPs, but I'm sure it's in there somewhere!

Thanks,
Ben

> 
> Alexey
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
