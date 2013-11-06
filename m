From: Alistair Popple <alistair@popple.id.au>
Subject: Re: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM emac driver
Date: Wed, 06 Nov 2013 12:38:37 +1100
Message-ID: <9250529.5UedqhaNce@mexican>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au> <81419762.0SyAdYsUqu@mexican> <CAGVrzcYzBtDcxYXDopOJn_=vW_58SFs9y0uKeGNB9TDPh6J4wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:12474 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753495Ab3KFBiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 20:38:05 -0500
In-Reply-To: <CAGVrzcYzBtDcxYXDopOJn_=vW_58SFs9y0uKeGNB9TDPh6J4wg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Nov 2013 16:16:08 Florian Fainelli wrote:

[snip]

> 2013/11/5 Alistair Popple <alistair@popple.id.au>:
> >> Any reasons why you are duplicating what is available in
> >> drivers/of/of_net.c ::of_get_phy_mode()?
> > 
> > Unless I'm missing something of_get_phy_mode() is going the other way.
> > rgmii_mode_name() is converting PHY_MODE_* into a human-readable string. I
> > couldn't find any obvious kernel method to do this but maybe I missed it?
> 
> Right, rgmii_mode_name() just has informative purposes and should be
> removed, I would suggest using standard device tree bindings property
> (phy-mode) anyway such that you could use of_get_phy_mode() and use
> phy_interface_t types.

Ok, that's what is currently done in the core IBM EMAC driver. As this is used 
just for informative purposes I will remove it. Thanks.

Regards,

Alistair
