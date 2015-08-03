From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [RFC PATCH 0/2] net: macb: Add mdio driver for accessing multiple
 phy devices
Date: Mon, 3 Aug 2015 08:01:05 +0200
Message-ID: <55BF03A1.8000001@xilinx.com>
References: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
 <55ACF7FC.4020408@xilinx.com> <55B5DFAF.4040909@atmel.com>
 <03CA77BA8AF6F1469AEDFBDA1322A7B749FC9CBA@XAP-PVEXMBX02.xlnx.xilinx.com>
 <20150731215307.GA27700@nathan3500-linux-VM>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Florian Fainelli" <f.fainelli@gmail.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"Harini Katakam" <harinik@xilinx.com>,
	"kpc528@gmail.com" <kpc528@gmail.com>,
	"kalluripunnaiahchoudary@gmail.com"
	<kalluripunnaiahchoudary@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nathan Sullivan <nathan.sullivan@ni.com>,
	Punnaiah Choudary Kalluri
	<punnaiah.choudary.kalluri@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0077.outbound.protection.outlook.com ([157.56.110.77]:6320
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752333AbbHCGfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2015 02:35:50 -0400
In-Reply-To: <20150731215307.GA27700@nathan3500-linux-VM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 07/31/2015 11:53 PM, Nathan Sullivan wrote:
> On Tue, Jul 28, 2015 at 03:34:51AM +0000, Punnaiah Choudary Kalluri wrote:
>> Ok. I will send you updated patch for mdio support soon and we will finalize next
>> Course of actions if it doesn't break the existing flow. 
>>
>> Thanks,
>> Punnaiah
> 
> Just a heads up, when mdio no longer turns off when macb goes down, the micrel
> 9031 phy will have an issue with interrupts getting disabling during phy
> suspend.  I have a patch to correct this issue here:
> 
> https://patchwork.ozlabs.org/patch/502189/
> 
> Would you mind including this patch in your set?

You should resend the patch again and you got one more argument why this
patch should go it. But it should go in own direction out of this patch.

Thanks,
Michal
