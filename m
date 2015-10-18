From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC
 device
Date: Sat, 17 Oct 2015 23:15:53 -0500
Message-ID: <alpine.DEB.2.02.1510172314290.20377@linux-builds1>
References: <1445028545-22599-1-git-send-email-andrew@lunn.ch> <alpine.DEB.2.02.1510161749490.25648@linux-builds1> <20151016235042.GA28795@lunn.ch> <alpine.DEB.2.02.1510170920160.12375@linux-builds1> <20151017204558.GA8727@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0077.outbound.protection.outlook.com ([157.56.111.77]:29376
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754470AbbJREWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Oct 2015 00:22:52 -0400
In-Reply-To: <20151017204558.GA8727@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Oct 2015, Andrew Lunn wrote:

> > Sure, will try to debug. It looks like phydev->attached_dev is valid, but
> > phydev->attached_dev->dev.of_node is NULL.
> 
> Humm
> 
> phydev->attached_dev is a net_device, so should be the mac.  What
> device is phydev->attached_dev->dev? Is it not the dev embedded in the
> platform_device passed to socfpga_dwmac_probe()?
>

Yes, it looks like it is, the dev->of_node is valid in socfpga_dwmac_probe(),
but it looks like of_node is getting lost somewhere. 

BR,
Dinh
