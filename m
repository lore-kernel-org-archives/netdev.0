From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 1/2] net: macb: Correct CAPS mask
Date: Fri, 5 Aug 2016 09:48:14 +0530
Message-ID: <CAFcVEC+s3d9Lpz54PBygDXC-1s75WJcPxGxb8202gEuaerJDGw@mail.gmail.com>
References: <1470036023-22368-1-git-send-email-harinik@xilinx.com> <f4a7d36f-2686-f8ae-35aa-ca5902cc9197@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Harini Katakam <harini.katakam@xilinx.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	"michals@xilinx.com" <michals@xilinx.com>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f4a7d36f-2686-f8ae-35aa-ca5902cc9197@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 4, 2016 at 7:37 PM, Nicolas Ferre <nicolas.ferre@atmel.com> wrote:
> Le 01/08/2016 à 09:20, Harini Katakam a écrit :
>> USRIO and JUMBO CAPS have the same mask.
>> Fix the same.
>>
>> Signed-off-by: Harini Katakam <harinik@xilinx.com>
>
> Hi,
> Indeed there's a bug...
>
>
>> ---
>>  drivers/net/ethernet/cadence/macb.h | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
>> index 36893d8..b6fcf10 100644
>> --- a/drivers/net/ethernet/cadence/macb.h
>> +++ b/drivers/net/ethernet/cadence/macb.h
>> @@ -403,11 +403,11 @@
>>  #define MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII  0x00000004
>>  #define MACB_CAPS_NO_GIGABIT_HALF            0x00000008
>>  #define MACB_CAPS_USRIO_DISABLED             0x00000010
>> +#define MACB_CAPS_JUMBO                              0x00000020
>>  #define MACB_CAPS_FIFO_MODE                  0x10000000
>>  #define MACB_CAPS_GIGABIT_MODE_AVAILABLE     0x20000000
>>  #define MACB_CAPS_SG_DISABLED                        0x40000000
>>  #define MACB_CAPS_MACB_IS_GEM                        0x80000000
>> -#define MACB_CAPS_JUMBO                              0x00000010
>
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>
> Can you please send it independently without the RFC tag in the subject
> and with the following tags in the body as well:
>
> Fixes: ce721a702197 ("net: ethernet: cadence-macb: Add disabled usrio caps")
> Cc: stable@vger.kernel.org # v4.5+
>

Thanks Nicolas. I'll do that.

Regards,
Harini

>>  /* Bit manipulation macros */
>>  #define MACB_BIT(name)                                       \
>>
>
> Thanks, bye,
> --
> Nicolas Ferre
