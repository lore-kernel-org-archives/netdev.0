From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 01 Oct 2002 11:54:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D99EF6C.9030509@candelatech.com>
References: <Pine.GSO.4.30.0210011433300.18461-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <cfriesen@nortelnetworks.com>, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Tue, 1 Oct 2002, Chris Friesen wrote:
> 
> 
>>to be silently dropped by the kernel because userspace is sending faster
>>than they can get onto the wire during that tight loop.
>>
> 
> 
> So what happens when you find packets being dropped?
> AFAIK, a dropped voice packet is as good as dead whether local or remote.

If it is dropped locally, you can re-send in way less than 1 milisecond,
which is well within the realm of expected jitter.  You can also back off
for 5 miliseconds to alleviate congestion, which is still within acceptable
jitter.

If you think you sent it, but didn't actually send it, then it looks like
your network is shitting, when in fact your local machine is acting shitty.

Ben

> 
> 
>>Okay, so with IP_RECVERR set the case that Eric saw will not happen?  I
>>mean that sendto() will return with -1 and errno set to ENOBUFS?
> 
> 
> yes
> 
> cheers,
> jamal
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
