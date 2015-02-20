From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging
 operations
Date: Fri, 20 Feb 2015 03:18:43 +0100
Message-ID: <20150220021843.GG795@lunn.ch>
References: <1424201196-4901-3-git-send-email-f.fainelli@gmail.com>
 <54E54EF3.9020802@gmail.com>
 <20150219055953.GA14247@roeck-us.net>
 <54E61CFB.3010109@gmail.com>
 <20150219174640.GA6897@roeck-us.net>
 <54E676DD.9090003@gmail.com>
 <20150220000935.GA30118@roeck-us.net>
 <54E68512.6070108@cumulusnetworks.com>
 <20150220010352.GA300@roeck-us.net>
 <54E691F2.5090205@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, cphealy@gmail.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46372 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753575AbbBTCVi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2015 21:21:38 -0500
Content-Disposition: inline
In-Reply-To: <54E691F2.5090205@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Remember that we are dealing with hardware switch chips. Those chips
> >won't time out fdb entries just because the kernel's bridge driver
> >thinks that it should.

> Oh, they dont..?

To some extent, it is better to think of these as two switches
connected to each other, not one switch. The HW switch needs help with
STP, but otherwise it is a fully functional and autonomous switch.

This is going to make displaying the forwarding database interesting,
because the SW bridge fdb and the HW bridge fdb are each subsets of
the big picture and possible even contradictory since they are not
updated atomically.

	Andrew
