From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/3] net/fsl: remove irq assignment from xgmac_mdio
Date: Wed, 24 Dec 2014 13:51:13 +0300
Message-ID: <549A9AA1.4020806@cogentembedded.com>
References: <1419328019-27254-1-git-send-email-shh.xie@gmail.com> <54997817.6010108@cogentembedded.com> <DM2PR0301MB08643B456EB87328ACF71CC5E2540@DM2PR0301MB0864.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "shh.xie@gmail.com" <shh.xie@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Shaohui Xie <Shaohui.Xie@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:63701 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbaLXKvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 05:51:17 -0500
Received: by mail-la0-f53.google.com with SMTP id gm9so6681534lab.40
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 02:51:15 -0800 (PST)
In-Reply-To: <DM2PR0301MB08643B456EB87328ACF71CC5E2540@DM2PR0301MB0864.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/24/2014 5:22 AM, Shaohui Xie wrote:

[...]

>>> From: Shaohui Xie <Shaohui.Xie@freescale.com>

>>> Which is wrong and not used, so no extra space needed by
>>> mdio_alloc_size(), change the parameter accordingly.

>>> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
>>> ---
>>>    drivers/net/ethernet/freescale/xgmac_mdio.c | 3 +--
>>>    1 file changed, 1 insertion(+), 2 deletions(-)

>>> diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c
>>> b/drivers/net/ethernet/freescale/xgmac_mdio.c
>>> index 90adba1..72e0b85 100644
>>> --- a/drivers/net/ethernet/freescale/xgmac_mdio.c
>>> +++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
>>> @@ -187,14 +187,13 @@ static int xgmac_mdio_probe(struct platform_device *pdev)
>>>    		return ret;
>>>    	}
>>>
>>> -	bus = mdiobus_alloc_size(PHY_MAX_ADDR * sizeof(int));
>>> +	bus = mdiobus_alloc_size(0);

>>      It's now equivalent to a mere mdiobus_alloc().

> [S.H] Yes, mdiobus_alloc() defined as:

> static inline struct mii_bus *mdiobus_alloc(void)
> {
>          return mdiobus_alloc_size(0);
> }

> Should I use mdiobus_alloc() instead?

    Yes, I meant it.

> Thanks!
> Shaohui

WBR, Sergei
