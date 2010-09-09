From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH v3] cxacru: ignore cx82310_eth devices
Date: Wed, 8 Sep 2010 20:35:57 -0700
Message-ID: <20100909033557.GA3723@kroah.com>
References: <201009051901.13851.linux@rainbow-software.org> <201009052212.37015.linux@rainbow-software.org> <20100908.131227.28827971.davem@davemloft.net> <201009082252.15865.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, simon@fire.lp0.eu,
	dbrownell@users.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:35792 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118Ab0IIFWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Sep 2010 01:22:14 -0400
Content-Disposition: inline
In-Reply-To: <201009082252.15865.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 08, 2010 at 10:52:12PM +0200, Ondrej Zary wrote:
> Ignore ADSL routers, which can have the same vendor and product IDs
> as ADSL modems but should be handled by the cx82310_eth driver.
> 
> This intentionally ignores device IDs that aren't currently handled
> by cx82310_eth. There may be other device IDs that perhaps shouldn't
> be claimed by cxacru.

Looks good, thanks, I'll go queue it up.

greg k-h
