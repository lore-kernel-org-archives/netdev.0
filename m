From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2] CS89x0 : Use ioread16/iowrite16 on all platforms
Date: Tue, 15 May 2012 16:08:34 -0700
Message-ID: <1337123314.7050.26.camel@joe2Laptop>
References: <1337112906-31033-1-git-send-email-jaccon.bastiaansen@gmail.com>
	 <20120515223711.GA12674@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>, arnd@arndb.de,
	s.hauer@pengutronix.de, gfm@funxed.com, davem@davemloft.net,
	festevam@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35922 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S966714Ab2EOXIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 19:08:36 -0400
In-Reply-To: <20120515223711.GA12674@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-16 at 00:37 +0200, Francois Romieu wrote:
> Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com> :
> [...]
> > diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
> > index b9406cb..8081ad5 100644
> > --- a/drivers/net/ethernet/cirrus/cs89x0.c
> > +++ b/drivers/net/ethernet/cirrus/cs89x0.c
> [...]
> > -static int cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular);
> > +static int cs89x0_probe1(struct net_device *dev,
> > +			 void __iomem *ioaddr,
> > +			 int modular);
> > +static int cs89x0_probe1(struct net_device *dev, void __iomem *ioaddr,
> > +			 int modular);
> 
> s/int/bool/ maybe.
> 
> You may skip the name of the parameters.

Better would be to not duplicate the prototype
and better still would be to reorder the code to
avoid the prototype altogether.
