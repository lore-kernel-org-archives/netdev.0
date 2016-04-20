From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] MAINTAINERS: net: add entry for TI Ethernet Switch
 drivers
Date: Wed, 20 Apr 2016 19:18:20 +0300
Message-ID: <5717ABCC.50406@ti.com>
References: <1461151509-2368-1-git-send-email-grygorii.strashko@ti.com>
 <20160420142350.GD5995@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Sekhar Nori <nsekhar@ti.com>, <linux-omap@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Richard Cochran <richardcochran@gmail.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:53455 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbcDTQS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 12:18:28 -0400
In-Reply-To: <20160420142350.GD5995@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2016 05:23 PM, Tony Lindgren wrote:
> * Grygorii Strashko <grygorii.strashko@ti.com> [160420 04:26]:
>> Add record for TI Ethernet Switch Driver CPSW/CPDMA/MDIO HW
>> (am33/am43/am57/dr7/davinci) to ensure that related patches
>> will go through dedicated linux-omap list.
>>
>> Also add Mugunthan as maintainer and myself as the reviewer.
>>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Mugunthan V N <mugunthanvnm@ti.com>
>> Cc: Richard Cochran <richardcochran@gmail.com>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>>   MAINTAINERS | 8 ++++++++
>>   1 file changed, 8 insertions(+)
>>
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index 1d5b4be..aca864d 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -11071,6 +11071,14 @@ S:	Maintained
>>   F:	drivers/clk/ti/
>>   F:	include/linux/clk/ti.h
>>   
>> +TI ETHERNET SWITCH DRIVER (CPSW)
>> +M:	Mugunthan V N <mugunthanvnm@ti.com>
>> +R:	Grygorii Strashko <grygorii.strashko@ti.com>
>> +L:	linux-omap@vger.kernel.org
>> +S:	Maintained
>> +F:	drivers/net/ethernet/ti/cpsw*
>> +F:	drivers/net/ethernet/ti/davinci*
>> +
>>   TI FLASH MEDIA INTERFACE DRIVER
>>   M:	Alex Dubov <oakad@yahoo.com>
>>   S:	Maintained
>> -- 
> 
> Please add netdev list also there as the primary list:
> 
> L:	netdev@vger.kernel.org
> L:	linux-omap@vger.kernel.org
> 
> Then we can easily review and ack the patches for Dave to apply.
> 

I can, but want clarify if it really necessary, because get_maintainer.pl
automatically adds netdev@vger.kernel.org:

./scripts/get_maintainer.pl ~/.../0001-drivers-net-cpsw-fix-port_mask-parameters-in-ale-cal.patch 
Mugunthan V N <mugunthanvnm@ti.com> (maintainer:TI ETHERNET SWITCH DRIVER (CPSW))
Grygorii Strashko <grygorii.strashko@ti.com> (reviewer:TI ETHERNET SWITCH DRIVER (CPSW))
linux-omap@vger.kernel.org (open list:TI ETHERNET SWITCH DRIVER (CPSW))
netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
linux-kernel@vger.kernel.org (open list)
 


-- 
regards,
-grygorii
