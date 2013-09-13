From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH v2 1/1] net: fec: fix phy reset operation to let imx6sl
 evk work
Date: Fri, 13 Sep 2013 01:37:21 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE016D08F1@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1378865937-12055-1-git-send-email-B38611@freescale.com>
 <20130912.171251.883636431449078988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Li Frank-B20596 <B20596@freescale.com>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:8757 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756862Ab3IMBhY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 21:37:24 -0400
In-Reply-To: <20130912.171251.883636431449078988.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller [mailto:davem@davemloft.net]
Data: Friday, September 13, 2013 5:13 AM

> To: Duan Fugang-B38611
> Cc: shawn.guo@linaro.org; netdev@vger.kernel.org;
> bhutchings@solarflare.com; stephen@networkplumber.org; Li Frank-B20596;
> s.hauer@pengutronix.de
> Subject: Re: [PATCH v2 1/1] net: fec: fix phy reset operation to let
> imx6sl evk work
> 
> From: Fugang Duan <B38611@freescale.com>
> Date: Wed, 11 Sep 2013 10:18:57 +0800
> 
> > Current driver only do phy reset in probe function, which is not
> > right. Since some phy clock is disabled after module probe, the phy
> > enter abnormal status, which needs do reset to recovery the phy. And
> > do ifconfig ethx up/down test, the phy also enter abnormal status.
> 
> What would disable the PHY clock after the probe?
> 
> You have to explain these kinds of things in your changelog message.
> 
> Thanks.
David,  there have another patch to saving ethernet power, which will disable phy
And MAC clock after module probe. The patch also include the information to explain
Some cases.

Of course, current Linux-next ethernet cannot work for imx6sl evk platform just because the 
Reset operation is not correct, have no dependency on saving power patch. 

Thanks,
Andy
