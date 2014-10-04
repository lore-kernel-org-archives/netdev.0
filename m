From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH] drivers/net/can/m_can/Kconfig: Let CAN_M_CAN depend on
 HAS_IOMEM
Date: Sat, 04 Oct 2014 19:49:26 +0800
Message-ID: <542FDEC6.3010507@gmail.com>
References: <542FC556.6060306@gmail.com> <542FD466.6080603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Varka Bhadram <varkabhadram@gmail.com>, wg@grandegger.com,
	mkl@pengutronix.de, fengguang.wu@intel.com, b29396@freescale.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <542FD466.6080603@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/4/14 19:05, Varka Bhadram wrote:
> Hi Chen Gang
> 
> 
> I think commit message should be short and proper.
> 
> We can remove *drivers/net/can/m_can/Kconfig* in the commit, just
> give *can: Kconfig: *
> 
> commit message like : *can: Kconfig: Fix CAN_M_CAN dependency*
> 

OK, thanks, it sounds good to me. If necessary to send patch v2 for it,
please let me know.

Thanks.

> On Saturday 04 October 2014 03:30 PM, Chen Gang wrote:
>> CAN_M_CAN needs HAS_IOMEM, so depend on it, the related error (with
>> allmodconfig under um):
>>
>>      MODPOST 1205 modules
>>    ERROR: "devm_ioremap" [drivers/net/can/m_can/m_can.ko] undefined!
>>    ERROR: "devm_ioremap_resource" [drivers/net/can/m_can/m_can.ko] undefined!
>>
>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
>> ---
>>   drivers/net/can/m_can/Kconfig | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/can/m_can/Kconfig b/drivers/net/can/m_can/Kconfig
>> index fca5482..14c9fcf 100644
>> --- a/drivers/net/can/m_can/Kconfig
>> +++ b/drivers/net/can/m_can/Kconfig
>> @@ -1,4 +1,5 @@
>>   config CAN_M_CAN
>>       tristate "Bosch M_CAN devices"
>> +    depends on HAS_IOMEM
>>       ---help---
>>         Say Y here if you want to support for Bosch M_CAN controller.
> 

-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
