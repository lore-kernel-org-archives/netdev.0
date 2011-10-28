From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] i825xx: Fix incorrect dependency for BVME6000_NET
Date: Fri, 28 Oct 2011 17:07:19 -0400 (EDT)
Message-ID: <20111028.170719.83478415752607807.davem@davemloft.net>
References: <1319835212-19473-1-git-send-email-geert@linux-m68k.org>
	<1319835584.10258.159.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319835584.10258.159.camel@jtkirshe-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 28 Oct 2011 13:59:43 -0700

> On Fri, 2011-10-28 at 13:53 -0700, Geert Uytterhoeven wrote:
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>> ---
>>  drivers/net/ethernet/i825xx/Kconfig |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
>> index 2be4698..ca1ae98 100644
>> --- a/drivers/net/ethernet/i825xx/Kconfig
>> +++ b/drivers/net/ethernet/i825xx/Kconfig
>> @@ -85,7 +85,7 @@ config APRICOT
>>  
>>  config BVME6000_NET
>>  	tristate "BVME6000 Ethernet support"
>> -	depends on BVME6000MVME16x
>> +	depends on BVME6000
>>  	---help---
>>  	  This is the driver for the Ethernet interface on BVME4000 and
>>  	  BVME6000 VME boards.  Say Y here to include the driver for this chip
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks everyone.
