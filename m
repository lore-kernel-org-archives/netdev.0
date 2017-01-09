From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 2/2] ARM: dts: dra72-evm-revc: enable irqs for dp83867 eth
 phys
Date: Mon, 9 Jan 2017 13:25:14 -0600
Message-ID: <cd8cdb56-ca47-6e17-43b4-daedc7889612@ti.com>
References: <20170106205543.4748-1-grygorii.strashko@ti.com>
 <20170106215451.GI2630@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>, <linux-omap@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>, <netdev@vger.kernel.org>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:22779 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750980AbdAITZU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:25:20 -0500
In-Reply-To: <20170106215451.GI2630@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/06/2017 03:54 PM, Tony Lindgren wrote:
> * Grygorii Strashko <grygorii.strashko@ti.com> [170106 12:56]:
>> TI DRA72-EVM Rev C has two DP83867 ethernet phys which support IRQ
>> generation in case of phy/link status changes. The INT/PWDN lines from both
>> DP83867 phys are wired to DRA7 gpio6.16, so reflect the same in DT.
>
> Hmm not seeing the patch 1/2 here.. Can this one be queued separately?
> Is it for v4.11 or a fix?

This is for next (v4.11) and there is just a mistake in subj, Sry.

>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>>  arch/arm/boot/dts/dra72-evm-revc.dts | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/arm/boot/dts/dra72-evm-revc.dts b/arch/arm/boot/dts/dra72-evm-revc.dts
>> index c3d939c..3ecac56 100644
>> --- a/arch/arm/boot/dts/dra72-evm-revc.dts
>> +++ b/arch/arm/boot/dts/dra72-evm-revc.dts
>> @@ -68,6 +68,8 @@
>>  		ti,tx-internal-delay = <DP83867_RGMIIDCTL_250_PS>;
>>  		ti,fifo-depth = <DP83867_PHYCR_FIFO_DEPTH_8_B_NIB>;
>>  		ti,min-output-impedance;
>> +		interrupt-parent = <&gpio6>;
>> +		interrupts = <16 IRQ_TYPE_EDGE_FALLING>;
>>  	};
>>
>>  	dp83867_1: ethernet-phy@3 {
>> @@ -75,6 +77,8 @@
>>  		ti,rx-internal-delay = <DP83867_RGMIIDCTL_2_25_NS>;
>>  		ti,tx-internal-delay = <DP83867_RGMIIDCTL_250_PS>;
>>  		ti,fifo-depth = <DP83867_PHYCR_FIFO_DEPTH_8_B_NIB>;
>> -		ti,min-output-imepdance;
>> +		ti,min-output-impedance;
>> +		interrupt-parent = <&gpio6>;
>> +		interrupts = <16 IRQ_TYPE_EDGE_FALLING>;
>>  	};
>>  };
>> --
>> 2.10.1.dirty
>>

-- 
regards,
-grygorii
