From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging
 operations
Date: Fri, 20 Feb 2015 03:02:41 +0100
Message-ID: <20150220020241.GF795@lunn.ch>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
 <1424201196-4901-3-git-send-email-f.fainelli@gmail.com>
 <54E54EF3.9020802@gmail.com>
 <20150219055953.GA14247@roeck-us.net>
 <54E61CFB.3010109@gmail.com>
 <20150219174640.GA6897@roeck-us.net>
 <54E676DD.9090003@gmail.com>
 <20150220000935.GA30118@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, cphealy@gmail.com
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46359 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752304AbbBTCFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2015 21:05:34 -0500
Content-Disposition: inline
In-Reply-To: <20150220000935.GA30118@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Not sure yet what to do about setting the fdb aging time. I don't
> see a mechanism to do that. No idea how important that is.

Hi Guenter

I don't know about your chip, but the public data sheet for the
88e6060 talks about being able to set the age time globally in the ATU
control register. The granularity is not so good, multiple of 16
seconds, so it could be the hardware bridge times out an entry faster
than the software bridge.

	 Andrew
