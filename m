From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 1/6] net: ethernet: ti: netcp: add support of cpts
Date: Mon, 5 Dec 2016 12:25:57 -0600
Message-ID: <7a484f9c-a47d-3ccd-9611-d00b86feabdd@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-2-grygorii.strashko@ti.com>
 <20161205144918.oj4jpj65aha3x5gf@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161205144918.oj4jpj65aha3x5gf@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/05/2016 08:49 AM, Rob Herring wrote:
> On Mon, Nov 28, 2016 at 05:04:23PM -0600, Grygorii Strashko wrote:
>> From: WingMan Kwok <w-kwok2@ti.com>
>>
>> This patch adds support of the cpts device found in the
>> gbe and 10gbe ethernet switches on the keystone 2 SoCs
>> (66AK2E/L/Hx, 66AK2Gx).
>>
>> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>>  .../devicetree/bindings/net/keystone-netcp.txt     |   9 +
>>  drivers/net/ethernet/ti/Kconfig                    |   7 +-
>>  drivers/net/ethernet/ti/netcp.h                    |   2 +-
>>  drivers/net/ethernet/ti/netcp_core.c               |  18 +-
>>  drivers/net/ethernet/ti/netcp_ethss.c              | 437 ++++++++++++++++++++-
>>  5 files changed, 459 insertions(+), 14 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
>> index 04ba1dc..c37b54e 100644
>> --- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
>> +++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
>> @@ -113,6 +113,15 @@ Optional properties:
>>  				will only initialize these ports and attach PHY
>>  				driver to them if needed.
>>  
>> + Properties related to cpts configurations.
>> +	- cpts_clock_mult/cpts_clock_shift:
> 
> Needs vendor prefix. Don't use '_'.

This module is used as part of OMAP and Keystone SoCs, so names for
this props is ABI already :(

> 
>> +		used for converting time counter cycles to ns as in
>> +
>> +		ns = (cycles * clock_mult) >> _shift
>> +
>> +		Defaults: clock_mult, clock_shift = calculated from
>> +		CPTS refclk
> 
> What does this mean?
> 

I'll add more description here.

>> +
>>  NetCP interface properties: Interface specification for NetCP sub-modules.
>>  Required properties:
>>  - rx-channel:	the navigator packet dma channel name for rx.

-- 
regards,
-grygorii
