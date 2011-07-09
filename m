From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH] net/fec: gasket needs to be enabled for some i.mx
Date: Sat, 9 Jul 2011 13:45:26 +0800
Message-ID: <20110709054526.GB13962@S2100-06.ap.freescale.net>
References: <20110630161935.GA7977@S2100-06.ap.freescale.net>
 <1309515082-7386-1-git-send-email-shawn.guo@linaro.org>
 <20110708101810.GE6069@pengutronix.de>
 <4E174E91.2090609@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Shawn Guo <shawn.guo@linaro.org>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<u.kleine-koenig@pengutronix.de>, <LW@KARO-electronics.de>,
	"David S. Miller" <davem@davemloft.net>
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:47922
	"EHLO CH1EHSOBE015.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751623Ab1GIFiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 01:38:55 -0400
Content-Disposition: inline
In-Reply-To: <4E174E91.2090609@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 08, 2011 at 11:38:09AM -0700, Troy Kisky wrote:
> On 7/8/2011 3:18 AM, Sascha Hauer wrote:
> > On Fri, Jul 01, 2011 at 06:11:22PM +0800, Shawn Guo wrote:
> >> On the recent i.mx (mx25/50/53), there is a gasket inside fec
> >> controller which needs to be enabled no matter phy works in MII
> >> or RMII mode.
> >>
> >> The current code enables the gasket only when phy interface is RMII.
> >> It's broken when the driver works with a MII phy.  The patch uses
> >> platform_device_id to distinguish the SoCs that have the gasket and
> >> enables it on these SoCs for both MII and RMII mode.
> >>
> >> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> 
> While you're making changes, you can change this to
> Reported-by: Troy Kisky
> 
Ok.

-- 
Regards,
Shawn

