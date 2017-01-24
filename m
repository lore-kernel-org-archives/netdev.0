From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/3] sh_eth: add missing EESIPR bits
Date: Tue, 24 Jan 2017 18:51:16 +0300
Message-ID: <f320226f-222a-2d3c-fa70-1e42f27c64f7@cogentembedded.com>
References: <1636105.gp4aQxGd5K@wasted.cogentembedded.com>
 <3805935.iR4tgtFiHm@wasted.cogentembedded.com>
 <CAMuHMdVED1D46zGkuSbpF22ZnKKjWcf50yRp-uT+LcBY_70xgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdVED1D46zGkuSbpF22ZnKKjWcf50yRp-uT+LcBY_70xgA@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/23/2017 10:41 AM, Geert Uytterhoeven wrote:

>> Renesas SH77{34|63} manuals  describe more EESIPR bits than the current
>> driver. Declare the new bits with the end goal of using the bit names
>> instead of the bare numbers  for  the 'sh_eth_cpu_data::eesipr_value'
>> initializers...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>
>
>> ---
>>  drivers/net/ethernet/renesas/sh_eth.h |   10 ++++++++--
>>  1 file changed, 8 insertions(+), 2 deletions(-)
>>
>> Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
>> ===================================================================
>> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
>> +++ net-next/drivers/net/ethernet/renesas/sh_eth.h
>> @@ -269,13 +269,17 @@ enum EESR_BIT {
>>
>>  /* EESIPR */
>>  enum EESIPR_BIT {
>> -       EESIPR_TWBIP    = 0x40000000,
>> +       EESIPR_TWB1IP   = 0x80000000,
>> +       EESIPR_TWBIP    = 0x40000000,   /* same as TWB0IP */
>
> Ah, your adding it here ;-)

    Do you want me to add such comment in the 1st patch instead?

> Gr{oetje,eeting}s,
>
>                         Geert

MRB, Sergei
