From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: usbnet: smsc95xx: fix link detection for disabled autonegotiation
Date: Thu, 26 May 2016 04:31:20 +0200
Message-ID: <20160526023120.GG21924@lunn.ch>
References: <1464228407.5421.34.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: Christoph Fritz <chf.fritz@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51970 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752436AbcEZCbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2016 22:31:24 -0400
Content-Disposition: inline
In-Reply-To: <1464228407.5421.34.camel@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 04:06:47AM +0200, Christoph Fritz wrote:
> To detect link status up/down for connections where autonegotiation is
> explicitly disabled, we don't get an irq but need to poll the status
> register for link up/down detection.
> This patch adds a workqueue to poll for link status.

Did you consider using the phylib? It probably does the needed polling
already, and it looks like the functions needed to implement an MDIO
bus are already in place.

    Andrew
