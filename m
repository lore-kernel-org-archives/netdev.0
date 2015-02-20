From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging
 operations
Date: Thu, 19 Feb 2015 20:07:44 -0800
Message-ID: <20150220040744.GC5017@roeck-us.net>
References: <54E61CFB.3010109@gmail.com>
 <20150219174640.GA6897@roeck-us.net>
 <54E676DD.9090003@gmail.com>
 <20150220000935.GA30118@roeck-us.net>
 <54E68512.6070108@cumulusnetworks.com>
 <20150220010352.GA300@roeck-us.net>
 <54E691F2.5090205@cumulusnetworks.com>
 <20150220021843.GG795@lunn.ch>
 <54E6A11A.2060703@cumulusnetworks.com>
 <20150220035237.GH795@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, cphealy@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:45228 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371AbbBTEH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 23:07:56 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YOese-002pI3-8I
	for netdev@vger.kernel.org; Fri, 20 Feb 2015 04:07:56 +0000
Content-Disposition: inline
In-Reply-To: <20150220035237.GH795@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 04:52:37AM +0100, Andrew Lunn wrote:
> > - we keep the SW bridge fdb in sync with the HW fdb, which leads to:
> 
> I don't think this is going to be easy or efficient. At least for the
> 88e6060 there is no interrupt when there is a change to the
> database. So we are going to have to poll. And the only way to figure
> out if anything has changed is to read it all out and compare against
> the last read.
> 
Agreed.

Guenter
