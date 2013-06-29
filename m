From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH net-next v2 1/1] net: fec: Add VLAN receive HW support.
Date: Sat, 29 Jun 2013 05:34:29 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE0150D3D1@039-SN2MPN1-023.039d.mgd.msft.net>
References: <Jim Baxter <jim_baxter@mentor.com>
 <1372428503-13744-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Li Frank-B20596 <B20596@freescale.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jim Baxter <jim_baxter@mentor.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:23503
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751356Ab3F2Fem convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jun 2013 01:34:42 -0400
In-Reply-To: <1372428503-13744-1-git-send-email-jim_baxter@mentor.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 06/28/13 22:08, Jim Baxter wrote:

> This enables the driver to take advantage of the FEC VLAN indicator to improve performance.
>
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> ---
> Change from v1 to v2
> Changed Max recieve Buffer Size Register from 1540 to 1536 so it is divisible by 64.
>
>  drivers/net/ethernet/freescale/fec.h      |    3 ++
>  drivers/net/ethernet/freescale/fec_main.c |   64 +++++++++++++++++++++++------
>  2 files changed, 55 insertions(+), 12 deletions(-)
> --
> 1.7.10.4

Acked-By: Fugang Duan  <B38611@freescale.com> 
