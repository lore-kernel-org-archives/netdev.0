From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: GMII2RGMII Converter support in macb driver
Date: Thu, 16 Jun 2016 07:18:19 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5B6C9F@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <C246CAC1457055469EF09E3A7AC4E11A4A57592E@XAP-PVEXMBX01.xlnx.xilinx.com>
 <570CF663.4000908@atmel.com> <570CFA1A.80702@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	Harini Katakam <harinik@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Michal Simek <michals@xilinx.com>
To: Phil Reid <preid@electromag.com.au>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0059.outbound.protection.outlook.com ([104.47.36.59]:26229
	"EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751276AbcFPIxT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 04:53:19 -0400
In-Reply-To: <570CFA1A.80702@electromag.com.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Phil Reid and Nicolas for your suggestions.

> >>
> >>
> >>
> >> But doing above changes making driver looks odd.
> >>
> >> could you please suggest any better option to add support for this IP
> >> in the macb driver?
> >
> > Appana,
> >
> > I certainly can't prototype the solution based on your datasheet and
> > the code sent... do a sensible proposal, then we can evaluate.
> >
> > As the IP is separated from the Eth controller, make it a separate
> > driver (an emulated phy one for instance... even if I don't know if it
> > makes sense).
> >
> > I don't know if others have already made such an adaptation layer
> > between GMII to RGMII but I'm pretty sure it can't be inserted into
> > the macb driver.
> >
> > Bye,
> >
> This sounds very similar to the altera emac-splitter.
> See stmmac driver for how they handled this.

I went through the flow of the stmmac driver but seems to me
It won't suit for my requirement as soc-fpga itself emulates as MAC.
But for gmii2rgmii converter it is not the case I am looking for a solution
Where it can be worked as an emulated PHY driver which doesn't have any
Vendor/Device ID's.

I saw this thread http://lists.openwall.net/netdev/2013/03/05/50 
But seems to be there are no further discussions.

Please let me know if you have any suggestions...

Regards,
Kedar.
