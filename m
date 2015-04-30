From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 7/8] net: dsa: mv88e6060: make it a proper
 PHY driver
Date: Thu, 30 Apr 2015 19:02:53 +0200
Message-ID: <20150430170253.GD18874@lunn.ch>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
 <1430359064-23454-8-git-send-email-f.fainelli@gmail.com>
 <554232E9.5080104@roeck-us.net>
 <55425C53.6060509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
	davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, cphealy@gmail.com,
	mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44821 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541AbbD3RHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 13:07:33 -0400
Content-Disposition: inline
In-Reply-To: <55425C53.6060509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The net advantage I see with this approach is that currently, with DSA,
> you get to do the following:
> 
> - register a "dsa" platform device
> - force your CPU Ethernet MAC to hardcode link parameters, either via a
> "fixed PHY" or via custom settings (ala mv643xx_eth)
> - probing needs to occur in a *very* specific order: MDIO first,
> Ethernet device second, DSA last

I'm not sure this is true. I'm pretty sure i've seen DSA return with
-EPROBE_DEFER and try again later.

      Andrew
