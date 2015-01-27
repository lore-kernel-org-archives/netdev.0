From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [net-next] net: netcp: remove unused kconfig option and code
Date: Tue, 27 Jan 2015 09:43:19 -0500
Message-ID: <54C7A407.1080509@ti.com>
References: <1421781756-11151-1-git-send-email-m-karicheri2@ti.com> <20150123.222120.467596005244092508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:40703 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932262AbbA0OnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 09:43:22 -0500
In-Reply-To: <20150123.222120.467596005244092508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2015 01:21 AM, David Miller wrote:
> From: Murali Karicheri<m-karicheri2@ti.com>
> Date: Tue, 20 Jan 2015 14:22:36 -0500
>
>> Currently CPTS is built into the netcp driver even though there is no
>> call out to the CPTS driver. This patch removes the dependency in Kconfig
>> and remove cpts.o from the Makefile for NetCP.
>>
>> Signed-off-by: Murali Karicheri<m-karicheri2@ti.com>
>> ---
>>   drivers/net/ethernet/ti/Kconfig  |    2 +-
>>   drivers/net/ethernet/ti/Makefile |    2 +-
>>   2 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
>> index e11bcfa..824e376 100644
>> --- a/drivers/net/ethernet/ti/Kconfig
>> +++ b/drivers/net/ethernet/ti/Kconfig
>> @@ -73,7 +73,7 @@ config TI_CPSW
>>   config TI_CPTS
>>   	boolean "TI Common Platform Time Sync (CPTS) Support"
>>   	depends on TI_CPSW
>> -	depends on TI_CPSW || TI_KEYSTONE_NET
>> +	depends on TI_CPSW
>
> Just remove the second dependency line, it's redundant because you've
> made it identical to the line before it.
Ok. Will post it with the change

-- 
Murali Karicheri
Linux Kernel, Texas Instruments
