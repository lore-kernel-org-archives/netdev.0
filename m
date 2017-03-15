From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net] amd-xgbe: Fix jumbo MTU processing on newer hardware
Date: Wed, 15 Mar 2017 17:40:51 -0500
Message-ID: <fce6d38d-6115-641d-ec68-47c2311021ce@amd.com>
References: <20170315201123.12279.98988.stgit@tlendack-t1.amdoffice.net>
 <20170315.153710.150813448900229829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0061.outbound.protection.outlook.com ([104.47.33.61]:43348
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751416AbdCOWlA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 18:41:00 -0400
In-Reply-To: <20170315.153710.150813448900229829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/2017 5:37 PM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Wed, 15 Mar 2017 15:11:23 -0500
>
>> Newer hardware does not provide a cumulative payload length when multiple
>> descriptors are needed to handle the data. Once the MTU increases beyond
>> the size that can be handled by a single descriptor, the SKB does not get
>> built properly by the driver.
>>
>> The driver will now calculate the size of the data buffers used by the
>> hardware.  The first buffer of the first descriptor is for packet headers
>> or packet headers and data when the headers can't be split. Subsequent
>> descriptors in a multi-descriptor chain will not use the first buffer. The
>> second buffer is used by all the descriptors in the chain for payload data.
>> Based on whether the driver is processing the first, intermediate, or last
>> descriptor it can calculate the buffer usage and build the SKB properly.
>>
>> Tested and verified on both old and new hardware.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>
> Applied, thanks Tom.

Thanks David.  This is another patch for 4.10 stable. Can you please
queue it up?

Thanks,
Tom

>
