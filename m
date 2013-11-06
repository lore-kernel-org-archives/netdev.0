From: Alistair Popple <alistair@popple.id.au>
Subject: Re: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM emac driver
Date: Wed, 06 Nov 2013 11:08:35 +1100
Message-ID: <81419762.0SyAdYsUqu@mexican>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au> <1383629471-16979-3-git-send-email-alistair@popple.id.au> <CAGVrzcZQ26kbim2piOwrvpyOcSaTET5da7Yh4GWv+erfuOBDhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:14597 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755607Ab3KFAIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 19:08:07 -0500
In-Reply-To: <CAGVrzcZQ26kbim2piOwrvpyOcSaTET5da7Yh4GWv+erfuOBDhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Nov 2013 10:47:22 Florian Fainelli wrote:
> [snip]
> 
> > +/* RGMII bridge supports only GMII/TBI and RGMII/RTBI PHYs */
> > +static inline int rgmii_valid_mode(int phy_mode)
> > +{
> > +       return  phy_mode == PHY_MODE_GMII ||
> > +               phy_mode == PHY_MODE_MII ||
> > +               phy_mode == PHY_MODE_RGMII ||
> > +               phy_mode == PHY_MODE_TBI ||
> > +               phy_mode == PHY_MODE_RTBI;
> > +}
> > +
> > +static inline const char *rgmii_mode_name(int mode)
> > +{
> > +       switch (mode) {
> > +       case PHY_MODE_RGMII:
> > +               return "RGMII";
> > +       case PHY_MODE_TBI:
> > +               return "TBI";
> > +       case PHY_MODE_GMII:
> > +               return "GMII";
> > +       case PHY_MODE_MII:
> > +               return "MII";
> > +       case PHY_MODE_RTBI:
> > +               return "RTBI";
> > +       default:
> > +               BUG();
> > +       }
> 
> Any reasons why you are duplicating what is available in
> drivers/of/of_net.c ::of_get_phy_mode()?

Unless I'm missing something of_get_phy_mode() is going the other way. 
rgmii_mode_name() is converting PHY_MODE_* into a human-readable string. I 
couldn't find any obvious kernel method to do this but maybe I missed it?

Regards,

Alistair
