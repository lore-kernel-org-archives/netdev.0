From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] net: Add 405EX support to new EMAC driver
Date: Thu, 1 Nov 2007 22:31:11 +0100
Message-ID: <200711012231.11385.sr@denx.de>
References: <200711011554.04935.sr@denx.de> <1193949421.6541.10.camel@pasglop> <20071101160709.7e7c0181@weaponx.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:62846 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbXKAVb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 17:31:28 -0400
In-Reply-To: <20071101160709.7e7c0181@weaponx.rchland.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 01 November 2007, Josh Boyer wrote:
> > > -	if (dev->type != RGMII_AXON)
> > > -		return;
> > > -
> > >  	mutex_lock(&dev->lock);
> >
> > That will break 440GX boards that need to use the RGMII for data and the
> > ZMII for MDIO.
> >
> > You may want to change the name RGMII_AXON something like RGMII_HAS_MDIO
> > instead and set that for 405EX as well instead.
>
> And perhaps adding a comment about that since the meaning of that code
> isn't very obvious. That way people that aren't the original author
> of the driver don't get confused again.

Will do. I'll send a fixed version tomorrow.

Best regards,
Stefan
