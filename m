From: Anatolij Gustschin <agust@denx.de>
Subject: Re: [PATCH] can: mpc5xxx_can.c: Fix build failure
Date: Mon, 31 May 2010 20:54:23 +0200
Message-ID: <20100531205423.0840fd08@wker>
References: <1275323499-15543-1-git-send-email-agust@denx.de>
	<4C03FF75.3010208@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:33943 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756201Ab0EaSy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 14:54:28 -0400
In-Reply-To: <4C03FF75.3010208@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wolfgang,

On Mon, 31 May 2010 20:27:01 +0200
Wolfgang Grandegger <wg@grandegger.com> wrote:
...
> > @@ -251,7 +251,7 @@ static int __devinit mpc5xxx_can_probe(struct of_device *ofdev,
> >  				       const struct of_device_id *id)
> >  {
> >  	struct mpc5xxx_can_data *data = (struct mpc5xxx_can_data *)id->data;
> > -	struct device_node *np = ofdev->node;
> > +	struct device_node *np = ofdev->dev.of_node;
> >  	struct net_device *dev;
> >  	struct mscan_priv *priv;
> >  	void __iomem *base;
> 
> The patch seems incomplete. I get at least one more warning (because
> I'm compiling for 52xx, I guess):

Yes, this is true. Unfortunately I didn't compile for 5200 and the issue
didn't show up.

>   CC      drivers/net/can/mscan/mpc5xxx_can.o
> drivers/net/can/mscan/mpc5xxx_can.c: In function 'mpc52xx_can_get_clock':
> drivers/net/can/mscan/mpc5xxx_can.c:76: error: 'struct of_device' has no member named 'node'
> 
> Should I send v2? Thanks for fixing that. I also checked the
> sja1000_of_platform driver,  which was converted correctly.

I will send v2 patch shortly. Thanks for reporting!

Anatolij
