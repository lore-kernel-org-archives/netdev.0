From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Microsemi VSC 8531/41 PHY Driver
Date: Tue, 16 Aug 2016 21:41:32 +0200
Message-ID: <20160816194132.GA2951@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A145329E4A@avsrvexchmbx1.microsemi.net>
 <20160726115556.GC11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A145329E97@avsrvexchmbx1.microsemi.net>
 <20160726124347.GD11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A14532A1E3@avsrvexchmbx1.microsemi.net>
 <20160729081736.GB13798@lunn.ch>
 <20160805122420.GA3184@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36238 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbcHPTle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 15:41:34 -0400
Content-Disposition: inline
In-Reply-To: <20160805122420.GA3184@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 05, 2016 at 05:54:21PM +0530, Nagaraju Lakkaraju wrote:
> Hello,
> 
> I added all review comments and re-sending for review.
> 
> >From a5017f5878a92d2acec86a6a29b1498c457cb73a Mon Sep 17 00:00:00 2001
> From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> Date: Wed, 3 Aug 2016 18:28:24 +0530
> Subject: [PATCH v2] net: phy: Add drivers for Microsemi PHYs

Please use git send-email to send patches.

All comments which should not be committed to the change log should
appear after the ---. It is normal to briefly list changes between
this version and the previous version.

> +static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
> +{
> +       int rc;
> +
> +       rc = phy_write(phydev, MSCC_EXT_PAGE_ACCESS, page);
> +       return rc;

Please remove rc and just do

	return phy_write(phydev, MSCC_EXT_PAGE_ACCESS, page);

> +}
> +
> +static int vsc85xx_default_config(struct phy_device *phydev)

This function is setting the RGMII delay. So vsc85xx_default_config()
is not a particularly good name.

   Andrew
