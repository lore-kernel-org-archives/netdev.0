From: Phil Reid <preid@electromag.com.au>
Subject: Re: [PATCH v2 5/5] stmmac: socfpga: Provide dt node to config ptp clk
 source.
Date: Mon, 7 Dec 2015 21:34:29 +0800
Message-ID: <56658AE5.7020108@electromag.com.au>
References: <1449452324-53858-1-git-send-email-preid@electromag.com.au>
 <1449452324-53858-7-git-send-email-preid@electromag.com.au>
 <2600741.aLNrbYNOOu@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	devicetree@vger.kernel.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy1.45ru.net.au ([203.30.46.145]:52117 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753586AbbLGNeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 08:34:37 -0500
In-Reply-To: <2600741.aLNrbYNOOu@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/12/2015 5:05 PM, Arnd Bergmann wrote:
> On Monday 07 December 2015 09:38:44 Phil Reid wrote:
>> Signed-off-by: Phil Reid <preid@electromag.com.au>
>> ---
>>   Documentation/devicetree/bindings/net/socfpga-dwmac.txt | 2 ++
>>   drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c     | 9 +++++++++
>>   2 files changed, 11 insertions(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
>> index 3a9d679..72d82d6 100644
>> --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
>> +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
>> @@ -11,6 +11,8 @@ Required properties:
>>                    designware version numbers documented in stmmac.txt
>>    - altr,sysmgr-syscon : Should be the phandle to the system manager node that
>>      encompasses the glue register, the register offset, and the register shift.
>> + - altr,f2h_ptp_ref_clk use f2h_ptp_ref_clk instead of default eosc1 clock
>> +   for ptp ref clk. This affects all emacs as the clock is common.
>>
>
> Is this feature specific to the Altera glue logic, or would it be possible
> to do the same thing on another dwmac implementation?
>
I think it is specific to Altera's glue logic. It selects either a clock connected
directly to the ARM HPS core or a clock routed from Altera FPGA fabric.
Control register is in the altera sysmgr.

-- 
Regards
Phil Reid
