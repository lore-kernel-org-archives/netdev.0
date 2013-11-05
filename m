From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM
 emac driver
Date: Wed, 06 Nov 2013 06:54:00 +1100
Message-ID: <1383681240.4776.97.camel@pasglop>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au>
	 <1383629471-16979-3-git-send-email-alistair@popple.id.au>
	 <1383675404.2868.8.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alistair Popple <alistair@popple.id.au>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34570 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758Ab3KETyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 14:54:22 -0500
In-Reply-To: <1383675404.2868.8.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-05 at 18:16 +0000, Ben Hutchings wrote:
> On Tue, 2013-11-05 at 16:31 +1100, Alistair Popple wrote:
> [...]
> > --- a/drivers/net/ethernet/ibm/emac/Kconfig
> > +++ b/drivers/net/ethernet/ibm/emac/Kconfig
> > @@ -55,6 +55,10 @@ config IBM_EMAC_RGMII
> >  	bool
> >  	default n
> >  
> > +config IBM_EMAC_RGMII_WOL
> > +	bool
> > +	default n
> > +
> [...]
> 
> So no-one can even build-test this at present!

Patch 7/7 adds the select to the platform, isn't that sufficient ?

It's an SoC bit so there's little point making it generally
selectable by the user.

Alistair: The commit name should be different, it's not a PHY you are
adding, it's a PHY interface (the PHY itself is off chip).

Cheers,
Ben.
