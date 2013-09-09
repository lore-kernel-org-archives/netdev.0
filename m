From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [RFC PATCH 4/4] ARM: dts: am33xx: adopt to cpsw-phy-sel driver
 to configure phy mode
Date: Mon, 9 Sep 2013 12:12:47 +0530
Message-ID: <522D6DE7.5080305@ti.com>
References: <1378639438-27686-1-git-send-email-mugunthanvnm@ti.com> <1378639438-27686-5-git-send-email-mugunthanvnm@ti.com> <522CBC15.5060008@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <zonque@gmail.com>,
	<davem@davemloft.net>, <bcousson@baylibre.com>, <tony@atomide.com>,
	<devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:39030 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab3IIGnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 02:43:03 -0400
In-Reply-To: <522CBC15.5060008@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 08 September 2013 11:34 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 09/08/2013 03:23 PM, Mugunthan V N wrote:
>
>> Add DT entries for the phy mode selection in AM33xx SoC using
>> cpsw-phy-sel
>> driver.
>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>> ---
>>   arch/arm/boot/dts/am33xx.dtsi | 6 ++++++
>>   1 file changed, 6 insertions(+)
>
>> diff --git a/arch/arm/boot/dts/am33xx.dtsi
>> b/arch/arm/boot/dts/am33xx.dtsi
>> index f9c5da9..4359672 100644
>> --- a/arch/arm/boot/dts/am33xx.dtsi
>> +++ b/arch/arm/boot/dts/am33xx.dtsi
>> @@ -594,6 +594,12 @@
>>                   /* Filled in by U-Boot */
>>                   mac-address = [ 00 00 00 00 00 00 ];
>>               };
>> +
>> +            phy_sel: cpsw_phy_sel@44e10650 {
>
>    Dashes are preferred to uderscores in the device tree names. 
I tried with dashes but i get the below error.

$ make CROSS_COMPILE=arm-linux-gnueabihf- ARCH=arm dtbs
  DTC     arch/arm/boot/dts/am335x-evm.dtb
Error: arch/arm/boot/dts/am33xx.dtsi:598.11-12 syntax error
FATAL ERROR: Unable to parse input tree
make[1]: *** [arch/arm/boot/dts/am335x-evm.dtb] Error 1
make: *** [dtbs] Error 2

Regards
Mugunthan V N
