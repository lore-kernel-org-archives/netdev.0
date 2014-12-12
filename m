From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: Bug: mv643xxx fails with highmem
Date: Fri, 12 Dec 2014 05:34:01 +0000
Message-ID: <BLUPR03MB37339496B52755D0F32B002F5600@BLUPR03MB373.namprd03.prod.outlook.com>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk>
	<20141211.151055.817876561546126576.davem@davemloft.net>
	<20141211202507.GS11285@n2100.arm.linux.org.uk>
 <20141211.152756.1471877201690056873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0146.outbound.protection.outlook.com ([157.56.111.146]:10990
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754261AbaLLFeF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 00:34:05 -0500
In-Reply-To: <20141211.152756.1471877201690056873.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net> Sent: Friday, December 12, 2014 4:28 AM
> To: linux@arm.linux.org.uk
> Cc: Duan Fugang-B38611; Estevam Fabio-R49496; ezequiel.garcia@free-
> electrons.com; netdev@vger.kernel.org
> Subject: Re: Bug: mv643xxx fails with highmem
> 
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Thu, 11 Dec 2014 20:25:07 +0000
> 
> > Would other drivers need fixing for this as well?  Eg, fec_main.c does
> > the following, and this driver is used on iMX6 which can also have
> > highmem:
> >
> > static int
> > fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
> >                              struct sk_buff *skb,
> >                              struct net_device *ndev) {
> >                 bufaddr = page_address(this_frag->page.p) +
> > this_frag->page_offset; ...
> >                 addr = dma_map_single(&fep->pdev->dev, bufaddr,
> frag_len,
> >                                       DMA_TO_DEVICE);
> 
> Probably, yes.

Hi, all,

I will submit one patch to fix the issue.

Regards,
Andy
