From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Tue, 11 Jun 2002 23:49:23 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae6r2o$n1j$2@main.gmane.org>
References: <Pine.LNX.4.44.0206120930160.29780-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Mielke <mark@mark.mielke.cc>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
List-Id: netdev.vger.kernel.org



Pekka Savola wrote:

> On Tue, 11 Jun 2002, Ben Greear wrote:
> 
>>If they are useful to some people, and have zero performance affect on others
>>(due to being a configurable kernel feature), then what is your
>>complaint?
>>
> 
> 3) Added features and complexity makes it more difficult to maintain the 
> kernel (you could say this is a variant of 1)


Adding counters to structures generally is not going to increase
complexity (especially when you comment the code).  It would increase
the code size slightly.

The code to bump the counters should also be extremely simple
(surely we don't drop packets in more than just a few places).

So, in this case, the increase in complexity seems pretty minimal.


> 4) Patches that have only a little debugging/etc. value are probably 
> useful, but mainly for a specific set of people, and this would seem to be 
> best handled by external patches.


External-only patches almost always rot, and are extremely hard to really
share across organizations.  Still, point taken.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
