From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Mon, 2 Sep 2013 02:23:00 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE0167E411@039-SN2MPN1-021.039d.mgd.msft.net>
References: <1377837325-5232-1-git-send-email-B38611@freescale.com>
 <20130830.175909.1743525148095642605.davem@davemloft.net>
 <9848F2DB572E5649BA045B288BE08FBE0167B047@039-SN2MPN1-021.039d.mgd.msft.net>
 <1F990F8245A4214A8CC4BFFBD9F790F908B40731@039-SN1MPN1-001.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>
To: Li Frank-B20596 <B20596@freescale.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0253.outbound.messaging.microsoft.com ([213.199.154.253]:12406
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753785Ab3IBCXK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Sep 2013 22:23:10 -0400
In-Reply-To: <1F990F8245A4214A8CC4BFFBD9F790F908B40731@039-SN1MPN1-001.039d.mgd.msft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Frank-B20596
Data: Monday, September 02, 2013 10:10 AM + 800

> To: Duan Fugang-B38611; David Miller
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
> l.stach@pengutronix.de
> Subject: RE: [PATCH] net: fec: fix the error to get the previous BD entry
> 
> >
> > Due to get tx & rx previous description use the same function
> > fec_enet_get_prevdesc(). If put the logic into
> > fec_enet_get_prevdesc(), I think it is better to split the function to
> > fec_enet_get_tx_prevdesc(),fec_enet_get_rx_prevdesc().
> >
> > If you agree it, I will submit one patch to do it.
> 
> It doesn't looks good to split to two functions.
> Can we use if (p == fep->tx_base || p == fep->rx_base) to check if get
> first entry of queue?

Yes, this check can get the first entry of queue, but the ring size is different for rx and tx ring.
In current driver, there have no tx/rx ring size variable define in struct fec_enet_private.

And, if change fec_enet_get_prevdesc(), the fec_enet_get_nextdesc() may need to do related logic change for nicety code.
 
> Best regards
> Frank Li
