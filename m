From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 2/5] sh_eth: enable wake-on-lan for Gen2 devices
Date: Sun, 18 Dec 2016 00:52:58 +0300
Message-ID: <f433b87e-c228-fa2c-b563-3cd5a7ab9546@cogentembedded.com>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
 <20161212160931.6478-3-niklas.soderlund+renesas@ragnatech.se>
 <eeff27f9-25eb-a981-33a9-15aa98ce9db1@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <eeff27f9-25eb-a981-33a9-15aa98ce9db1@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/14/2016 04:37 PM, Sergei Shtylyov wrote:

>> Tested on Gen2 r8a7791/Koelsch.
>>
>> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
>> ---
>>  drivers/net/ethernet/renesas/sh_eth.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index 87640b9..348ed22 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -624,8 +624,9 @@ static struct sh_eth_cpu_data r8a779x_data = {
>>
>>      .register_type    = SH_ETH_REG_FAST_RCAR,
>>
>> -    .ecsr_value    = ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
>> -    .ecsipr_value    = ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
>> +    .ecsr_value    = ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD | ECSR_MPD,
>> +    .ecsipr_value    = ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP |
>> +              ECSIPR_MPDIP,
>
>   These expressions seem to have been sorted by the bit # before your patch,
> now they aren't... care to fix? :-)

    After looking at the SH7743/64 code, nevermind this request. Sorry. :-)

MBR, Sergei
