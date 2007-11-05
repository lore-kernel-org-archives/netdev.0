From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] net: Add 405EX support to new EMAC driver
Date: Mon, 5 Nov 2007 12:11:34 +0100
Message-ID: <200711051211.35452.sr@denx.de>
References: <200711020814.43524.sr@denx.de> <200711051019.04287.sr@denx.de> <1194260652.6511.70.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jwboyer@linux.vnet.ibm.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:53877 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184AbXKELLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 06:11:48 -0500
In-Reply-To: <1194260652.6511.70.camel@pasglop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 November 2007, Benjamin Herrenschmidt wrote:
> > So how exactly do you want me to handle this (I'm still new to this
> > device
> > tree stuff, so please bear with me)? Like this?
> >
> >                         RGMII0: emac-rgmii@ef601000 {
> >                                 device_type = "rgmii-interface";
> >                                 compatible = "ibm,rgmii-405ex",
> > "ibm,rgmii";
> >                                 reg = <ef601000 8>;
> >                                 has-mdio;
> >                         };
>
> The above.
>
> Properties without values are typically used for such "flags". I'll
> fixup the driver to also take that for the inverted STACR and will post
> a patch fixing that up asap.

OK, thanks. I'll wait with further 405ex emac patches until you changed this 
in the driver.

> > So perhaps most flexible would be to add individual properties,
> > like "stacr-oc-inverted" and "stacr-staopc-19-20". What do you think?
> > And
> > again the additional question: Should the be added as an new property
> > or
> > added to the compatible property?
>
> That's always the main question imho ... When it gets nasty like that I
> tend to think the compatible property is a good compromise. It's mostly
> a matter of taste. Unless you can come up with some more pleasant way to
> do it... maybe a stacr-type property with multiple values but it's
> really not worth complicating things when a compatible property will do
> the job just fine. In that case, it's not really a "feature" of a given
> implementation, but more about subtle differences between
> implementations.

OK.

Best regards,
Stefan
