From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: Re: [RFC PATCH 0/2] net: macb: Add mdio driver for accessing
 multiple phy devices
Date: Fri, 31 Jul 2015 16:53:07 -0500
Message-ID: <20150731215307.GA27700@nathan3500-linux-VM>
References: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
 <55ACF7FC.4020408@xilinx.com>
 <55B5DFAF.4040909@atmel.com>
 <03CA77BA8AF6F1469AEDFBDA1322A7B749FC9CBA@XAP-PVEXMBX02.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Michal Simek <michals@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Harini Katakam <harinik@xilinx.com>,
	"kpc528@gmail.com" <kpc528@gmail.com>,
	"kalluripunnaiahchoudary@gmail.com"
	<kalluripunnaiahchoudary@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod2.natinst.com ([130.164.80.23]:56629 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755428AbbGaVxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jul 2015 17:53:19 -0400
In-Reply-To: <03CA77BA8AF6F1469AEDFBDA1322A7B749FC9CBA@XAP-PVEXMBX02.xlnx.xilinx.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2015 at 03:34:51AM +0000, Punnaiah Choudary Kalluri wrote:
> Ok. I will send you updated patch for mdio support soon and we will finalize next
> Course of actions if it doesn't break the existing flow. 
> 
> Thanks,
> Punnaiah

Just a heads up, when mdio no longer turns off when macb goes down, the micrel
9031 phy will have an issue with interrupts getting disabling during phy
suspend.  I have a patch to correct this issue here:

https://patchwork.ozlabs.org/patch/502189/

Would you mind including this patch in your set?
