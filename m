From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/2] Indirect phy access for mv88e6171
Date: Sun, 15 Feb 2015 21:25:11 +0100
Message-ID: <20150215202511.GH3213@lunn.ch>
References: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
 <54E0E648.8080206@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, f.fainelli@gmail.com
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44564 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932190AbbBOU2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Feb 2015 15:28:01 -0500
Content-Disposition: inline
In-Reply-To: <54E0E648.8080206@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'll try. My primary problem right now is that I run Lennert Buytenhek's
> patch set to support bridging offload (aka hardware bridging) on top of
> the upstream dsa code, and the upstream code now supports a competing /
> alternate means  to support bridging/switching offload (NET_SWITCHDEV)
> which doesn't work with dsa (at least not yet). So I'll have to figure
> out if / how I can run your patches with my code base, or how I can add
> add support for NET_SWITCHDEV into dsa.

We should be adding switchdev support to DSA for hardware
bridging. The concepts in Lennert Buytenhek's should be a good
starting point for this.
 
> Do you know if there are any efforts going on in that direction ?

Florian has expressed an interest in getting hardware bridging
working. I've no idea if he has looked at it from the perspective of
switchdev.

	Andrew
