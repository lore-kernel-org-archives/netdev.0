From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: replace devm_kzalloc() with devm_kmalloc()
Date: Mon, 12 May 2014 15:52:20 +0400
Message-ID: <5370B5F4.6020901@cogentembedded.com>
References: <201405120005.51199.sergei.shtylyov@cogentembedded.com> <1399853435.9156.1.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1399853435.9156.1.camel@joe-AO725>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/12/2014 04:10 AM, Joe Perches wrote:

>> Now that devm_kmalloc() has become available, we can avoid the needless
>> zeroing out of the PHY IRQ array.
> []
>> net-next/drivers/net/ethernet/renesas/sh_eth.c
> []
>> @@ -2627,7 +2627,7 @@ static int sh_mdio_init(struct sh_eth_pr
> []
>> -	mdp->mii_bus->irq = devm_kzalloc(dev, sizeof(int) * PHY_MAX_ADDR,
>> +	mdp->mii_bus->irq = devm_kmalloc(dev, sizeof(int) * PHY_MAX_ADDR,

> perhaps

> 	mdp->mii_bus->irq = devm_kmalloc_array(dev, PHY_MAX_ADDR, sizeof(int),

    Yes, that has occurred to me after I sent the patch...

WBR, Sergei

