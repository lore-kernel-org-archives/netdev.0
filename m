From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next 0/8] amd-xgbe: AMD XGBE driver update 2014-07-25
Date: Tue, 29 Jul 2014 08:21:23 -0500
Message-ID: <53D79FD3.5010407@amd.com>
References: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
 <20140728.173359.1659401063111761702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0185.outbound.protection.outlook.com ([207.46.163.185]:47090
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751587AbaG2NVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 09:21:36 -0400
In-Reply-To: <20140728.173359.1659401063111761702.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2014 07:33 PM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Fri, 25 Jul 2014 16:10:52 -0500
>
>> This patch series is dependent on the following patch that was
>> applied to the net tree and needs to be applied to the net-next
>> tree:
>>    332cfc823d18 - amd-xgbe: Fix error return code in xgbe_probe()
>>
>> The following series of patches includes fixes and new support in the
>> driver.
>>
>> - Device bindings documentation update
>> - Hardware timestamp support
>> - 2.5GbE support changes
>> - Fifo sizes based on active queues/rings
>> - Phylib driver updates for:
>>    - Rate change completion check
>>    - KR training initiation
>>    - Auto-negotiation results
>> - Traffic class support, including DCB support
>>
>> This patch series is based on net-next.
>
> I was going to apply this, but I couldn't let those function tracing debug
> giblets into the tree.
>
> Please remove all of that DBGPR(...., __func__) stuff.
>
> We have a generic function tracer which can be used to trace any path
> of execution in the kernel.
>

Will do. I was planning on going through the whole driver and replacing
all the DBGPR type functions in a future patch. For now I'll just
remove them from this patch series and address the rest of the driver
in a future patch.

Thanks,
Tom
