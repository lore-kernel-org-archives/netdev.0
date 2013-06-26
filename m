From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH net-next v1 1/1] net: fec: Add VLAN receive HW support.
Date: Wed, 26 Jun 2013 03:13:14 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE014FE6CC@039-SN2MPN1-023.039d.mgd.msft.net>
References: <jim_baxter@mentor.com>
 <1372204524-27798-1-git-send-email-jim_baxter@mentor.com>
 <9848F2DB572E5649BA045B288BE08FBE014FE4E1@039-SN2MPN1-023.039d.mgd.msft.net>
 <20130626025649.GA32202@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jim Baxter <jim_baxter@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	Li Frank-B20596 <B20596@freescale.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:15130
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751445Ab3FZDNk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 23:13:40 -0400
In-Reply-To: <20130626025649.GA32202@S2101-09.ap.freescale.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, you are right.

Before we sent our our patch, we must test it on all covered platforms.


Thanks,
Andy 

-----Original Message-----
From: Shawn Guo [mailto:shawn.guo@linaro.org] 
Sent: Wednesday, June 26, 2013 10:57 AM
To: Duan Fugang-B38611
Cc: Jim Baxter; David S. Miller; Li Frank-B20596; Estevam Fabio-R49496; Lucas Stach; netdev@vger.kernel.org; Ben Hutchings
Subject: Re: [PATCH net-next v1 1/1] net: fec: Add VLAN receive HW support.

On Wed, Jun 26, 2013 at 02:31:40AM +0000, Duan Fugang-B38611 wrote:
> In addition,
> 	1.	enet IP support hw VLAN detect such as imx28-fec, imx6q-fec and mvf600-fec, so you can add the "BD_ENET_RX_VLAN " to those platform driver_data.

I guess Jim only tested the code on imx6q-fec.  We shouldn't enable it for the other two platforms until it's been tested on them.  As the counter example, although we expect FEC_QUIRK_HAS_CSUM should also work for imx28-fec, if we enable FEC_QUIRK_HAS_CSUM for it, fec driver will just break right way on imx28.

Shawn
