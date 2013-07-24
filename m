From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH 05/13] tile: support PTP using the tilegx mPIPE (IEEE
 1588)
Date: Wed, 24 Jul 2013 12:17:31 -0400
Message-ID: <51EFFE1B.3050909@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com> <77f753af79722f39c5fa77cd35adefdd1634e5d5.1374609949.git.cmetcalf@tilera.com> <20130724062900.GB5163@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130724062900.GB5163@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/24/2013 2:29 AM, Richard Cochran wrote:
> On Tue, Jul 23, 2013 at 04:05:48PM -0400, Chris Metcalf wrote:
>
>> diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
>> index 5be73ba..255ed1a 100644
>> --- a/drivers/ptp/Kconfig
>> +++ b/drivers/ptp/Kconfig
>> @@ -87,4 +87,14 @@ config PTP_1588_CLOCK_PCH
>>  	  To compile this driver as a module, choose M here: the module
>>  	  will be called ptp_pch.
>>  
>> +config PTP_1588_CLOCK_TILEGX
>> +        tristate "Tilera TILE-Gx mPIPE as PTP clock"
>> +        select PTP_1588_CLOCK
>> +        depends on TILEGX
>> +        help
>> +          This driver adds support for using the mPIPE as a PTP
>> +          clock. This clock is only useful if your PTP programs are
>> +          getting hardware time stamps on the PTP Ethernet packets
>> +          using the SO_TIMESTAMPING API.
>> +
> Is this feature available on every TILEGX hardware variant?
> If not, then there needs to be some provision for that.

It is.

> Also, this option should probably appear under the main MAC option.

By that I assume you mean in drivers/net/ethernet/tile/Kconfig?  I will do that.

Thanks!

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
