From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: remove memory copy for rx path
Date: Sat, 27 Sep 2014 09:15:24 +0000
Message-ID: <057807be43ca4c79ad51ab07c668519d@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1411538730-31480-1-git-send-email-b38611@freescale.com>
 <20140926.170720.2230061639326332503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [157.56.111.119] ([157.56.111.119]:11424 "EHLO
	na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751156AbaI0JRS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 05:17:18 -0400
In-Reply-To: <20140926.170720.2230061639326332503.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net> Sent: Saturday, September 27, 2014 5:07 AM
>To: Duan Fugang-B38611
>Cc: Li Frank-B20596; netdev@vger.kernel.org; shawn.guo@linaro.org;
>bhutchings@solarflare.com
>Subject: Re: [PATCH] net: fec: remove memory copy for rx path
>
>From: Fugang Duan <b38611@freescale.com>
>Date: Wed, 24 Sep 2014 14:05:30 +0800
>
>> Re-allocate skb instead of memory copy skb data in rx path to improve
>> enet rx performance.
>>
>> Signed-off-by: Fugang Duan <B38611@freescale.com>
>> Signed-off-by: Frank Li <Frank.Li@freescale.com>
>
>For small packet sizes, copying is almost certainly faster and it avoids
>mismatched skb->truesize vs. skb->len which hurts TCP performance.
>
>We call this rx_copybreak, and there are many drivers you can look at to
>see how this works.
>
>Thanks.

Great suggestion. I will change it for next version.

Thanks,
Andy
