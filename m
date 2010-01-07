From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 07 Jan 2010 14:55:22 -0500
Message-ID: <4B463C2A.2090209@majjas.com>
References: <4B457711.1040008@majjas.com> <4B458B36.6050509@majjas.com>
 <20100107074756.GB6258@ff.dom.local> <4B459368.2000503@majjas.com>
 <4B45F841.8030407@majjas.com> <20100107180114.GB3088@del.dom.local>
 <4B4625BD.3070202@majjas.com> <20100107183545.GA3208@del.dom.local>
 <4B462B3C.90506@majjas.com> <20100107185040.GB3208@del.dom.local>
 <20100107193607.GC3208@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753965Ab0AGTz6@vger.kernel.org>
In-reply-to: <20100107193607.GC3208@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/7/2010 2:36 PM, Jarek Poplawski wrote:
> On Thu, Jan 07, 2010 at 07:50:40PM +0100, Jarek Poplawski wrote:
>    
>>> Going to rerun with these patches and with and without MMAP. Will
>>> also retry both with jumbo frames if possible.
>>>        
>> If MMAP then some "alternative" too. But first no MMAP.
>>      
> Another things IMHO worth to try: a sky2 module parameter
> "disable_msi=1", and CONFIG_DMAR off.
>
> Jarek P.
>    
Ok - that'd be with or without MMAP enabled? (note that so-far, without 
MMAP I'm not seeing any errors - throughput is running about half what I 
was seeing with MMAP enabled (before crashing that is). CPU is also way 
busier (also to be expected). One other observation - I had been seeing 
lots of DNS errors - IPV6 related format errors I really didn't think 
much of it as they were mostly .ru and seemed spam-related, but now I 
don't see any. Haven't updated bind; doubt the world has changed - so 
perhaps this is related to the network issue.
