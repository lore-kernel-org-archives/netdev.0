From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH][net-next v1] gianfar: Add flow control support
Date: Mon, 12 Aug 2013 10:09:16 +0300
Message-ID: <52088A1C.6010904@freescale.com>
References: <1376036790-18238-2-git-send-email-ljaenicke@innominate.com> <1376068786-29868-1-git-send-email-claudiu.manoil@freescale.com> <CAOMZO5CG3L3Jhjki-V7-jc+jBqRca_TTz_3e7=DP_1Zn8apZXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Lutz Jaenicke <ljaenicke@innominate.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:24999
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751471Ab3HLHOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 03:14:00 -0400
In-Reply-To: <CAOMZO5CG3L3Jhjki-V7-jc+jBqRca_TTz_3e7=DP_1Zn8apZXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right, thanks.
___
Claudiu

On 8/9/2013 8:36 PM, Fabio Estevam wrote:
> On Fri, Aug 9, 2013 at 2:19 PM, Claudiu Manoil
> <claudiu.manoil@freescale.com> wrote:
>
>> +static int gfar_spauseparam(struct net_device *dev,
>> +                           struct ethtool_pauseparam *epause)
>> +{
>> +       struct gfar_private *priv = netdev_priv(dev);
>> +       struct phy_device *phydev = priv->phydev;
>> +       struct gfar __iomem *regs = priv->gfargrp[0].regs;
>> +       u32 oldadv, newadv;
>> +       int err = 0;
>
> You could drop this 'err' variable, no?
>
> ...
>
>> +
>> +       return err;
>
> Then just 'return 0' here.
>
