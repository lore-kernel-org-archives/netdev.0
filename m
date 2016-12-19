From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 1/5] sh_eth: add generic wake-on-lan support via magic
 packet
Date: Mon, 19 Dec 2016 19:56:41 +0300
Message-ID: <45380308-8a49-3a0c-b4cb-502908ad983f@cogentembedded.com>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
 <20161212160931.6478-2-niklas.soderlund+renesas@ragnatech.se>
 <079800f0-2e80-7a0b-01e2-51e09f05345c@cogentembedded.com>
 <20161219164159.GF21006@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20161219164159.GF21006@bigcity.dyn.berto.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 12/19/2016 07:41 PM, Niklas Söderlund wrote:

[...]

>>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>>> index 05b0dc5..87640b9 100644
>>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
>>> index d050f37..4ceed00 100644
>>> --- a/drivers/net/ethernet/renesas/sh_eth.h
>>> +++ b/drivers/net/ethernet/renesas/sh_eth.h
>>> @@ -493,6 +493,7 @@ struct sh_eth_cpu_data {
>>>  	unsigned shift_rd0:1;	/* shift Rx descriptor word 0 right by 16 */
>>>  	unsigned rmiimode:1;	/* EtherC has RMIIMODE register */
>>>  	unsigned rtrate:1;	/* EtherC has RTRATE register */
>>> +	unsigned magic:1;	/* EtherC has ECMR.PMDE and ECSR.MPD */
>>
>>    After looking at the SH7734/63 manuals it became obvious that PMDE was a
>> result of typo, the bit is called MPDE actually, the current name doesn't
>> make sense anyway. Care to fix?
>
> Sure, I add fixup patch to the front of this series which cleans this up
> before adding WoL support.

    That would be fine, TIA!

[...]

MBR, Sergei
