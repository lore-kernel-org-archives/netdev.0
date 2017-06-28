From: Thor Thayer <thor.thayer@linux.intel.com>
Subject: Re: [PATCH 2/2] ethtool: stmmac: Add DMA HW Feature Register
Date: Wed, 28 Jun 2017 08:25:14 -0500
Message-ID: <1e300373-cacf-6630-a6fe-6014d58940a9@linux.intel.com>
References: <1498600275-22334-1-git-send-email-thor.thayer@linux.intel.com>
 <1498600275-22334-3-git-send-email-thor.thayer@linux.intel.com>
 <12583b41-540b-c0a9-4dfe-874d8d46709a@st.com>
Reply-To: thor.thayer@linux.intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50021 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751535AbdF1NWD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 09:22:03 -0400
In-Reply-To: <12583b41-540b-c0a9-4dfe-874d8d46709a@st.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2017 04:03 AM, Giuseppe CAVALLARO wrote:
> On 6/27/2017 11:51 PM, thor.thayer@linux.intel.com wrote:
>> From: Thor Thayer <thor.thayer@linux.intel.com>
>>
>> This patch adds the DMA HW Feature Register which is at the end
>> of the DMA registers and is documented in Version 3.70a.
>>
>> Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
>> ---
>>   stmmac.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/stmmac.c b/stmmac.c
>> index e1bb291..7d7bebd 100644
>> --- a/stmmac.c
>> +++ b/stmmac.c
>> @@ -64,7 +64,7 @@ int st_gmac_dump_regs(struct ethtool_drvinfo *info, 
>> struct ethtool_regs *regs)
>>       fprintf(stdout, "\n");
>>       fprintf(stdout, "DMA Registers\n");
>>       stmmac_reg = (unsigned int *)regs->data + DMA_REG_OFFSET;
>> -    for (i = 0; i < 22; i++)
>> +    for (i = 0; i < 23; i++)
> 
> thx Thor for these changes, I wonder if you could add a macro instead 23 
> while doing this kind of changes
> 
> Sorry if I didn't it in the past.
> 
> the, you can send the series with my Acked-by: Giuseppe Cavallaro 
> <peppe.cavallaro@st.com>
> 
> Regards
> 
> peppe
> 

Sure. I'll also add a macro for the # of main registers too (55). Some 
maintainers prefer the macros while others prefer the number to reduce 
the space.

Thanks for the quick review!

Thor
> 
>>           fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
>>       return 0;
> 
> 
> 
