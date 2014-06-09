From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH] amd-xgbe: Rename MAX_DMA_CHANNELS to avoid powerpc conflict
Date: Mon, 9 Jun 2014 10:17:38 -0500
Message-ID: <5395D012.9060804@amd.com>
References: <20140609141931.30639.72028.stgit@tlendack-t1.amdoffice.net>
 <063D6719AE5E284EB5DD2968C1650D6D17259A7D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "kbuild-all@01.org" <kbuild-all@01.org>,
	"jet.chen@intel.com" <jet.chen@intel.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fengguang.wu@intel.com" <fengguang.wu@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0184.outbound.protection.outlook.com ([207.46.163.184]:6415
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752169AbaFIPSG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 11:18:06 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17259A7D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2014 09:25 AM, David Laight wrote:
> From: Tom Lendacky
>> MAX_DMA_CHANNELS is defined in asm/scatterlist.h of the powerpc
>> architecture.  Rename this #define in xgbe.h to avoid the
>> redefined warning issued during compilation.
> ...
>> --- a/drivers/net/ethernet/amd/xgbe/xgbe.h
>> +++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
>> @@ -138,7 +138,7 @@
>>   #define RX_MIN_BUF_SIZE		(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
>>   #define RX_BUF_ALIGN		64
>>
>> -#define MAX_DMA_CHANNELS	16
>> +#define XGBE_MAX_DMA_CHANNELS	16
>>   #define DMA_ARDOMAIN_SETTING	0x2
>>   #define DMA_ARCACHE_SETTING	0xb
>>   #define DMA_AWDOMAIN_SETTING	0x2
>
> Might be worthwhile changing the other names at the same time.
>

I thought about that when creating this patch, but didn't want to
take it too far - just resolve the reported issue.

I'll submit a follow-on patch that renames the other defines if
that is acceptable.

Thanks,
Tom

> 	David
>
