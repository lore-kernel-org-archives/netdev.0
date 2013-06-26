From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH net-next v1 1/1] net: fec: Add VLAN receive HW support.
Date: Wed, 26 Jun 2013 10:56:56 +0800
Message-ID: <20130626025649.GA32202@S2101-09.ap.freescale.net>
References: <jim_baxter@mentor.com>
 <1372204524-27798-1-git-send-email-jim_baxter@mentor.com>
 <9848F2DB572E5649BA045B288BE08FBE014FE4E1@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jim Baxter <jim_baxter@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	Li Frank-B20596 <B20596@freescale.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:14677 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751424Ab3FZC5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 22:57:47 -0400
Content-Disposition: inline
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE014FE4E1@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 02:31:40AM +0000, Duan Fugang-B38611 wrote:
> In addition,
> 	1.	enet IP support hw VLAN detect such as imx28-fec, imx6q-fec and mvf600-fec, so you can add the "BD_ENET_RX_VLAN " to those platform driver_data.

I guess Jim only tested the code on imx6q-fec.  We shouldn't enable it
for the other two platforms until it's been tested on them.  As the
counter example, although we expect FEC_QUIRK_HAS_CSUM should also work
for imx28-fec, if we enable FEC_QUIRK_HAS_CSUM for it, fec driver will
just break right way on imx28.

Shawn
