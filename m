From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC
 device
Date: Sat, 17 Oct 2015 22:45:58 +0200
Message-ID: <20151017204558.GA8727@lunn.ch>
References: <1445028545-22599-1-git-send-email-andrew@lunn.ch>
 <alpine.DEB.2.02.1510161749490.25648@linux-builds1>
 <20151016235042.GA28795@lunn.ch>
 <alpine.DEB.2.02.1510170920160.12375@linux-builds1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Dinh Nguyen <dinguyen@opensource.altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42369 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750714AbbJQUqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 16:46:00 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1510170920160.12375@linux-builds1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sure, will try to debug. It looks like phydev->attached_dev is valid, but
> phydev->attached_dev->dev.of_node is NULL.

Humm

phydev->attached_dev is a net_device, so should be the mac.  What
device is phydev->attached_dev->dev? Is it not the dev embedded in the
platform_device passed to socfpga_dwmac_probe()?

	Andrew
