From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/6] net: fec: Factorize the .xmit transmit function
Date: Thu, 05 Jun 2014 15:17:52 -0700 (PDT)
Message-ID: <20140605.151752.1006020454313961670.davem@davemloft.net>
References: <d93f47b1073f46319b170dee27206bed@BLUPR03MB373.namprd03.prod.outlook.com>
	<063D6719AE5E284EB5DD2968C1650D6D17257ACC@AcuExch.aculab.com>
	<f3588131770d48dbbfa8387db06d6c23@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	shawn.guo@linaro.org, Fabio.Estevam@freescale.com,
	ezequiel.garcia@free-electrons.com, bhutchings@solarflare.com,
	stephen@networkplumber.org, Frank.Li@freescale.com,
	eric.dumazet@gmail.com
To: fugang.duan@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbaFEWRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:17:54 -0400
In-Reply-To: <f3588131770d48dbbfa8387db06d6c23@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Date: Thu, 5 Jun 2014 10:21:37 +0000

> You think the conditional has measurable performance impact on
> ethernet code paths, I agree your thinking.  But in the driver,
> there have many site/apis use the method.
> 
> So, I don't want to change it for the patch set.  It have no meaningful.
> I will submit another patch to solve all APIs with conditional for the driver.

You're adding this test, it did not exist beforehand.

For the second time I'm asking you to follow David Laight's feedback
seriously, every time he asks you to make a change your initial reaction
is to not do it, or to do it "later".  If it's for something this patch
set uniquely is doing, "later" is not an acceptable response.

I'm not applying this series until you intergrate his legitimate
feedback.

Thank you.
