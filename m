From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] New version of net timestamp optimization
Date: Wed, 30 Jun 2004 11:46:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E30A8E.6000507@candelatech.com>
References: <20040406182941.7e759f4c.ak@suse.de>	<1081340659.15893.117.camel@jzny.localdomain> <20040407143703.6af5bb71.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040407143703.6af5bb71.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On 07 Apr 2004 08:24:19 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> 
>>The patch does look clean and attractive. I havent had time toi play
>>with it myself - but given the way gettimeofday has been torturing me
>>i will at some point. Also if you have time a 2.4.x patch would be
> 
> 
> Thanks. All feedback I received so far was positive. I hope DaveM will
> merge it soon. I don't have plans to work on 2.4 anymore.

I finally got around to working with 2.6, and I ran into the
new timestamp code.  I would like to be able to have timestamps
even though I do not have a socket structure (I am using a kernel
module to grab all frames)...

How would you feel about either exporting the netstamp_needed variable
or offering a method that explicitly incremented or decremented the
use count?

Thanks,
Ben

> 
> -Andi
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
