From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net: fec: fix build warning of used uninitialized
 variable
Date: Fri, 30 Aug 2013 02:47:26 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE01662C52@039-SN2MPN1-021.039d.mgd.msft.net>
References: <1377165637-8116-1-git-send-email-B38611@freescale.com>
 <1F990F8245A4214A8CC4BFFBD9F790F908B16AA6@039-SN1MPN1-002.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Li Frank-B20596 <B20596@freescale.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:23894
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752333Ab3H3Crd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 22:47:33 -0400
In-Reply-To: <1F990F8245A4214A8CC4BFFBD9F790F908B16AA6@039-SN1MPN1-002.039d.mgd.msft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ping...

> -----Original Message-----
> From: Li Frank-B20596
> Sent: Thursday, August 22, 2013 10:16 PM
> To: Duan Fugang-B38611; Zhou Luwei-B45643; davem@davemloft.net
> Cc: netdev@vger.kernel.org; shawn.guo@linaro.org;
> bhutchings@solarflare.com; Estevam Fabio-R49496;
> stephen@networkplumber.org
> Subject: RE: [PATCH] net: fec: fix build warning of used uninitialized
> variable
> 
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index 77ea0db..4ea1555 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -835,7 +835,7 @@ fec_enet_rx(struct net_device *ndev, int budget)
> >  	int	pkt_received = 0;
> >  	struct	bufdesc_ex *ebdp = NULL;
> >  	bool	vlan_packet_rcvd = false;
> > -	u16	vlan_tag;
> > +	u16	vlan_tag = 0;
> >
> >  #ifdef CONFIG_M532x
> >  	flush_cache_all();
> 
> Acked
> 
> > --
> > 1.7.1
