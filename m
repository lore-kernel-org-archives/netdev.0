From: Shaohui Xie <shaohui.xie@nxp.com>
Subject: RE: [PATCHv3 net-next 2/3] phy: marvell: Add ethtool statistics
 counters
Date: Thu, 31 Dec 2015 05:24:28 +0000
Message-ID: <VI1PR04MB16643F2698CAADFCC43692CBE8FE0@VI1PR04MB1664.eurprd04.prod.outlook.com>
References: <1451418684-9238-1-git-send-email-andrew@lunn.ch>
 <1451418684-9238-3-git-send-email-andrew@lunn.ch>
 <VI1PR04MB1664FF303D53D9472E36452BE8FD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <20151230151257.GA16560@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0056.outbound.protection.outlook.com ([157.56.112.56]:22688
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750789AbbLaFjx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 00:39:53 -0500
In-Reply-To: <20151230151257.GA16560@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, December 30, 2015 11:13 PM
> To: Shaohui Xie
> Cc: David Miller; Florian Fainelli; netdev
> Subject: Re: [PATCHv3 net-next 2/3] phy: marvell: Add ethtool statistics
> counters
> 
> On Wed, Dec 30, 2015 at 04:24:40AM +0000, Shaohui Xie wrote:
> > > Subject: [PATCHv3 net-next 2/3] phy: marvell: Add ethtool statistics
> > > counters
> > > +static int marvell_probe(struct phy_device *phydev) {
> > > +	struct marvell_priv *priv;
> > > +
> > > +	priv = devm_kzalloc(&phydev->dev, sizeof(*priv), GFP_KERNEL);
> > > +	if (!priv)
> > > +		return -ENOMEM;
> > > +
> > > +	phydev->priv = priv;
> > > +
> > > +	return 0;
> > > +}
> > > +
> > [S.H] Is a remove() function needed to free the memory?
> 
> Hi Shaohui
> 
> No, since i use devm_kzalloc(). The memory will automatically be freed when
> phydev->dev is destroyed. Take a look at all the devm_ API calls which have this
> property. They are useful for avoiding memory leaks, especially on error paths.
Got it.
Thank you!

Shaohui
