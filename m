From: Dinh Nguyen <dinh.linux@gmail.com>
Subject: Re: [PATCH 2/3] dts: socfpga: Fix ethernet entries for the stmmac
Date: Wed, 26 Mar 2014 19:05:41 -0500
Message-ID: <53336B55.7080605@gmail.com>
References: <1395790482-3957-1-git-send-email-dinguyen@altera.com> <1395790482-3957-3-git-send-email-dinguyen@altera.com> <20140326221225.GP3998@book.gsilab.sittig.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, davem@davemloft.net, peppe.cavallaro@st.com,
	mark.rutland@arm.com, devicetree@vger.kernel.org,
	pawel.moll@arm.com, srinivas.kandagatla@st.com,
	netdev@vger.kernel.org, ijc+devicetree@hellion.org.uk,
	robh+dt@kernel.org, arm@kernel.org, galak@codeaurora.org,
	linux-arm-kernel@lists.infradead.org
To: Gerhard Sittig <gsi@denx.de>, dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:52537 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203AbaC0AFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 20:05:44 -0400
In-Reply-To: <20140326221225.GP3998@book.gsilab.sittig.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/26/2014 05:12 PM, Gerhard Sittig wrote:
> On Tue, 2014-03-25 at 18:34 -0500, dinguyen@altera.com wrote:
>>
>> -			#size-cells = <1>;
>> -			compatible = "altr,socfpga-stmmac";
>> -			altr,sysmgr-syscon = <&sysmgr 0x60>;
>> +		gmac0: ethernet@ff700000 {
>> +			compatible = "altr,socfpga-stmmac", "snps,dwmac-3.70a", "snps,dwmac";
>>   			status = "disabled";
>> -			ranges;
>> -
>> -			gmac0: gmac0@ff700000 {
>> -				compatible = "snps,dwmac-3.70a", "snps,dwmac";
>> -				reg = <0xff700000 0x2000>;
>> -				interrupts = <0 115 4>;
>> -				interrupt-names = "macirq";
>> -				mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
>> -				clocks = <&emac0_clk>;
>> -				clock-names = "stmmaceth";
>> -			};
>> +			altr,sysmgr-syscon = <&sysmgr 0x60>;
>> +			reg = <0xff700000 0x2000>;
>> +			interrupts = <0 115 4>;
>> +			interrupt-names = "macirq";
>> +			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
>> +			clocks = <&emac0_clk>;
>> +			clock-names = "stmmaceth";
>>   		};
>
> not strictly related to this patch, but noticed in bypassing:
>
> is the 'clocks' spec correct?  ISTR that 'emac0_clk' is the PLL
> output, while the gated clock for the EMAC IP block is named
> 'emac_0_clk' (note the extra underscore)
>

Yes, you're right. Thanks for catching that.

Dinh
>
> virtually yours
> Gerhard Sittig
>
