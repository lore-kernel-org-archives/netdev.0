From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: [PATCH 1/6] pch_gbe: print invalid MAC address during probe
Date: Wed, 28 May 2014 11:34:20 +0200
Message-ID: <9952617.kdfEWfEVqY@ws-stein>
References: <1401111639-11507-1-git-send-email-alexander.stein@systec-electronic.com> <1401121468.519.6.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Krueger <daniel.krueger@systec-electronic.com>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:41369 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751031AbaE1Jfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 05:35:53 -0400
In-Reply-To: <1401121468.519.6.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 26 May 2014 09:24:28, Joe Perches wrote:
> On Mon, 2014-05-26 at 15:40 +0200, Alexander Stein wrote:
> > show the actual offending MAC address instead of just
> > rejecting it
> []
> > diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> []
> > @@ -2674,6 +2674,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
> >  		 */
> >  		dev_err(&pdev->dev, "Invalid MAC address, "
> >  		                    "interface disabled.\n");
> > +		dev_err(&pdev->dev, "%pM\n", adapter->hw.mac.addr);
> 
> Nicer I think on a single line
> using just one dev_err
> 
> 		dev_err(&pdev->dev, "Invalid MAC %pM - interface disabled\n",
> 			adapter->hw.mac.addr);

Yep, I'll send a v2 if there is some more feedback on the other patches.

Best regards,
Alexander
