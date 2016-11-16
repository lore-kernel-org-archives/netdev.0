From: Greentime Hu <green.hu@gmail.com>
Subject: Re: [PATCH] net: ethernet: faraday: To support device tree usage.
Date: Wed, 16 Nov 2016 22:26:52 +0800
Message-ID: <CAEbi=3esyRi4cnUNf4uPKCQtyRekBRo81Frd=BSJy8qf=3uc+A@mail.gmail.com>
References: <1479285795-3105-1-git-send-email-green.hu@gmail.com> <20161116134715.GE19962@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161116134715.GE19962@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 16, 2016 at 9:47 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, Nov 16, 2016 at 04:43:15PM +0800, Greentime Hu wrote:
>> To support device tree usage for ftmac100.
>>
>> Signed-off-by: Greentime Hu <green.hu@gmail.com>
>> ---
>>  drivers/net/ethernet/faraday/ftmac100.c |    7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
>> index dce5f7b..81dd9e1 100644
>> --- a/drivers/net/ethernet/faraday/ftmac100.c
>> +++ b/drivers/net/ethernet/faraday/ftmac100.c
>> @@ -1172,11 +1172,17 @@ static int __exit ftmac100_remove(struct platform_device *pdev)
>>       return 0;
>>  }
>>
>> +static const struct of_device_id mac_of_ids[] = {
>> +     { .compatible = "andestech,atmac100" },
>> +     { }
>
> andestech is not in
> Documentation/devicetree/bindings/vendor-prefixes.txt Please provide a
> separate patch adding it.
OK. I will provide another patch to add andestech.

> Humm, why andestech? Why not something based around faraday
> technology?
It is because we use the same ftmac100 IP provided from faraday
technology but I am now using it in andestech SoC.
