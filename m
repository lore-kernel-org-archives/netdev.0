From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Mon, 2 Sep 2013 01:37:22 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE0167B047@039-SN2MPN1-021.039d.mgd.msft.net>
References: <1377837325-5232-1-git-send-email-B38611@freescale.com>
 <20130830.175909.1743525148095642605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Li Frank-B20596 <B20596@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0248.outbound.messaging.microsoft.com ([213.199.154.248]:19084
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753233Ab3IBBij convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Sep 2013 21:38:39 -0400
In-Reply-To: <20130830.175909.1743525148095642605.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Data: Saturday, August 31, 2013 5:59 AM

> To: Duan Fugang-B38611
> Cc: Li Frank-B20596; netdev@vger.kernel.org; bhutchings@solarflare.com;
> l.stach@pengutronix.de
> Subject: Re: [PATCH] net: fec: fix the error to get the previous BD entry
> 
> From: Fugang Duan <B38611@freescale.com>
> Date: Fri, 30 Aug 2013 12:35:25 +0800
> 
> > When the current BD is the first BD, the previous BD entry must be the
> > last BD, not "bdp - 1".
> >
> > Add BD entry check to get the previous BD entry correctly.
> >
> > Signed-off-by: Fugang Duan  <B38611@freescale.com>
> 
> The correct fix is to put this logic into fec_enet_get_prevdesc().
> With this current limitation, the function is completely useless.

Due to get tx & rx previous description use the same function fec_enet_get_prevdesc(). If put the logic into fec_enet_get_prevdesc(),
I think it is better to split the function to fec_enet_get_tx_prevdesc(),fec_enet_get_rx_prevdesc().

If you agree it, I will submit one patch to do it.

Thanks,
Andy
