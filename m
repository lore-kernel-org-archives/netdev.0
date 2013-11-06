From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM
 emac driver
Date: Wed, 06 Nov 2013 13:17:20 +1100
Message-ID: <1383704240.4776.115.camel@pasglop>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au>
	 <81419762.0SyAdYsUqu@mexican>
	 <CAGVrzcYzBtDcxYXDopOJn_=vW_58SFs9y0uKeGNB9TDPh6J4wg@mail.gmail.com>
	 <9250529.5UedqhaNce@mexican>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	"David S. Miller" <davem@davemloft.net>
To: Alistair Popple <alistair@popple.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39640 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579Ab3KFCRw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 21:17:52 -0500
In-Reply-To: <9250529.5UedqhaNce@mexican>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 12:38 +1100, Alistair Popple wrote:
> > Right, rgmii_mode_name() just has informative purposes and should be
> > removed, I would suggest using standard device tree bindings
> property
> > (phy-mode) anyway such that you could use of_get_phy_mode() and use
> > phy_interface_t types.
> 
> Ok, that's what is currently done in the core IBM EMAC driver. As this
> is used 
> just for informative purposes I will remove it. Thanks.

Why ? Information is useful...

Ben.
