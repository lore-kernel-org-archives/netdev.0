From: Sachin Sant <sachinp@in.ibm.com>
Subject: Re: [PowerPC] Next May 8 boot failure: OOPS during ibmveth moduleinit
Date: Mon, 11 May 2009 22:37:09 +0530
Message-ID: <4A085B3D.5000806@in.ibm.com>
References: <20090508180251.f53f204e.sfr@canb.auug.org.au>  <4A042B20.4090903@in.ibm.com> <20090508.125722.54378771.davem@davemloft.net> <20090508223332.GA4881@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-next@vger.kernel.org,
	linuxppc-dev@ozlabs.org, sfr@canb.auug.org.au,
	netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090508223332.GA4881@psychotron.englab.brq.redhat.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Pirko wrote:
> Fri, May 08, 2009 at 09:57:22PM CEST, davem@davemloft.net wrote:
>   
>> From: Sachin Sant <sachinp@in.ibm.com>
>> Date: Fri, 08 May 2009 18:22:48 +0530
>>
>>     
>>> Todays Next failed to boot on a Power6 JS22 blade with following oops.
>>>       
>> Jiri, I suspect this might be your address list changes.
>>
>> Although that's just a guess.  But please take a look.
>>     
>
> Hmm, only thing I see might cause the problem would be if calling __hw_addr_add
> in dev_addr_init fails, then dev->dev_addr would contain zeroes (which looks
> this is not the case). But in this case the oops would appear earlier (in
> ibmveth_probe dev_addr memcpy).
>
> Will do the patch which checks the result to behave correctly in case of oom
> but this imho this wouldn't help. Strange, I will dig into this more tomorrow.
>   
I can recreate this problem with today's Next release as well. Let me 
know if you want me to try
out any thing to debug this problem.

Thanks
-Sachin

-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------
