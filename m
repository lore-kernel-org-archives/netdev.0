From: Ben Greear <greearb@candelatech.com>
Subject: Re: BCM5704 performance questions.
Date: Fri, 10 Jun 2005 14:09:00 -0700
Message-ID: <42AA016C.9050801@candelatech.com>
References: <42A8E0FE.3020708@candelatech.com> <1118361376.5838.20.camel@rh4> <42A8EBDA.6010306@candelatech.com> <1118363861.5838.29.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1118363861.5838.29.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Thu, 2005-06-09 at 18:24 -0700, Ben Greear wrote:
> 
>>Michael Chan wrote:
>>
>>>Unfortunately, the 5704 requires the "ONE_DMA" workaround which will
>>>limit throughput in a PCIX 100/133 bus. If you comment out the line that
>>>sets the DMA_RWCTRL_ONE_DMA flag in tg3.c, you should see improved
>>>performance. However, you may run into some DMA issues on certain
>>>systems.
>>
>>Is there any way I can tell which systems are affected?  It won't be
>>an option for me to purposefully ship possibly busted drivers/hardware,
>>but if I can be certain that my systems are immune, I will try this
>>modification.
>>
> 
> I mentioned this so that you could verify that the slow performance was
> indeed caused by ONE_DMA. Even if your system is affected, it's a very
> subtle problem that won't show up right away and should allow you to get
> some performance numbers.

I commented out the code and ran the pktgen test again.  It may be a small
bit better, but not much:  770Mbps in one direction, 750Mbps in the other.

Have you done any tests with 2 tg3 NICs in a single machine to see if they
can run at or near line speed (full duplex)?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
