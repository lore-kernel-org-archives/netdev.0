From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] net: add Documentation/networking/scaling.txt
Date: Fri, 19 Aug 2011 10:38:17 -0700
Message-ID: <4E4E9F89.6010903@hp.com>
References: <alpine.DEB.2.00.1107312346350.28722@pokey.mtv.corp.google.com> <4E36F524.7090301@hp.com> <1313524404.2725.50.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, rdunlap@xenotime.net,
	linux-doc@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, willemb@google.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1313524404.2725.50.camel@bwh-desktop>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/16/2011 12:53 PM, Ben Hutchings wrote:
> On Mon, 2011-08-01 at 11:49 -0700, Rick Jones wrote:
>> On 07/31/2011 11:56 PM, Tom Herbert wrote:
>>> Describes RSS, RPS, RFS, accelerated RFS, and XPS.
>>>
>>> Signed-off-by: Tom Herbert<therbert@google.com>
>>> ---
>>>    Documentation/networking/scaling.txt |  346 ++++++++++++++++++++++++++++++++++
>>>    1 files changed, 346 insertions(+), 0 deletions(-)
>>>    create mode 100644 Documentation/networking/scaling.txt
>>>
>>> diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
>>> new file mode 100644
>>> index 0000000..aa51f0f
>>> --- /dev/null
>>> +++ b/Documentation/networking/scaling.txt
>>> @@ -0,0 +1,346 @@
>>> +Scaling in the Linux Networking Stack
>>> +
>>> +
>>> +Introduction
>>> +============
>>> +
>>> +This document describes a set of complementary techniques in the Linux
>>> +networking stack to increase parallelism and improve performance (in
>>> +throughput, latency, CPU utilization, etc.) for multi-processor systems.
>>
>> Why not just leave-out the parenthetical lest some picky pedant find a
>> specific example where either of those three are not improved?
>
> As I'm sure you're aware, there is often a trade-off between throughput
> and latency.  It might be useful to provide some guidelines for
> optimising each of the above.

Yes.  I just worry about taking *too* many steps down the slippery slope 
and ending-up ballooning into a broad systems tuning tutorial.

rick
