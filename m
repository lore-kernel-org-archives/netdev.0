From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Wed, 27 Feb 2013 13:42:41 -0800
Message-ID: <512E7DD1.1010209@candelatech.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com> <512E654A.2010209@hp.com> <512E6F23.3090003@linux.intel.com>
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
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <512E6F23.3090003@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/27/2013 12:40 PM, Eliezer Tamir wrote:
> On 27/02/2013 21:58, Rick Jones wrote:
>> On 02/27/2013 09:55 AM, Eliezer Tamir wrote:
>>>
>>> Performance numbers:
>>> Kernel   Config     C3/6  rx-usecs  TCP  UDP
>>> 3.8rc6   typical    off   adaptive  37k  40k
>>> 3.8rc6   typical    off   0*        50k  56k
>>> 3.8rc6   optimized  off   0*        61k  67k
>>> 3.8rc6   optimized  on    adaptive  26k  29k
>>> patched  typical    off   adaptive  70k  78k
>>> patched  optimized  off   adaptive  79k  88k
>>> patched  optimized  off   100       84k  92k
>>> patched  optimized  on    adaptive  83k  91k
>>> *rx-usecs=0 is usually not useful in a production environment.
>>
>> I would think that latency-sensitive folks would be using rx-usecs=0 in
>> production - at least if the NIC in use didn't have low enough latency
>> with its default interrupt coalescing/avoidance heuristics.
>
> It will only work well if you have no bulk traffic on the same port as the low latency traffic at all.

Have you done any tests for bulk throughput with busy-poll?  Yes, it will eat a core,
but that might be worth it in some cases if there was significant throughput increase...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
