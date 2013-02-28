From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Thu, 28 Feb 2013 10:38:37 +0200
Message-ID: <512F178D.5090601@linux.intel.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com> <512E654A.2010209@hp.com> <512E6F23.3090003@linux.intel.com> <512E7DD1.1010209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <512E7DD1.1010209@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/02/2013 23:42, Ben Greear wrote:
> On 02/27/2013 12:40 PM, Eliezer Tamir wrote:
>> On 27/02/2013 21:58, Rick Jones wrote:
>>> On 02/27/2013 09:55 AM, Eliezer Tamir wrote:
>>>> *rx-usecs=0 is usually not useful in a production environment.
>>>
>>> I would think that latency-sensitive folks would be using rx-usecs=0 in
>>> production - at least if the NIC in use didn't have low enough latency
>>> with its default interrupt coalescing/avoidance heuristics.
>>
>> It will only work well if you have no bulk traffic on the same port as
>> the low latency traffic at all.
>
> Have you done any tests for bulk throughput with busy-poll?  Yes, it
> will eat a core,
> but that might be worth it in some cases if there was significant
> throughput increase...

My impression was that most bulk use cases are handled exceptionally 
well by napi along with some kind of adaptive moderation scheme, esp. if 
you compare to cases where napi is not being used.

If you can recommend a specific use case where busy polling will be an 
advantage for bulk traffic, I will happily try it out.

Thanks,
Eliezer
