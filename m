From: Ben Greear <greearb@candelatech.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Mon, 16 Sep 2002 09:09:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D860246.3060609@candelatech.com>
References: <20020913222213.69396.qmail@web14006.mail.yahoo.com> <3D85DB3D.DC65A80B@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cacophonix <cacophonix@yahoo.com>, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Friesen wrote:
> Cacophonix wrote:
> 
>>--- Chris Friesen <cfriesen@nortelnetworks.com> wrote:
> 
> 
>>>This has always confused me.  Why doesn't the bonding driver try and spread
>>>all the traffic over all the links?
>>
>>Because then you risk heavy packet reordering within an individual flow,
>>which can be detrimental in some cases.
>>--karthik
> 
> 
> I can see how it could make the receiving host work more on reassembly, but if throughput is key,
> wouldn't you still end up better if you can push twice as many packets through the pipe?
> 
> Chris

Also, I notice lots of out-of-order packets on a single gigE link when running at high
speeds (SMP machine), so the kernel is still having to reorder quite a few packets.
Has anyone done any tests to see how much worse it is with dual-port bonding?

NAPI helps my problem, but does not make it go away entirely.

Ben

> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
