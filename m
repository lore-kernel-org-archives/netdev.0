From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging
 operations
Date: Thu, 19 Feb 2015 17:03:52 -0800
Message-ID: <20150220010352.GA300@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
 <1424201196-4901-3-git-send-email-f.fainelli@gmail.com>
 <54E54EF3.9020802@gmail.com>
 <20150219055953.GA14247@roeck-us.net>
 <54E61CFB.3010109@gmail.com>
 <20150219174640.GA6897@roeck-us.net>
 <54E676DD.9090003@gmail.com>
 <20150220000935.GA30118@roeck-us.net>
 <54E68512.6070108@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:51458 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbbBTBD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 20:03:57 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YOc0a-000z1L-Cj
	for netdev@vger.kernel.org; Fri, 20 Feb 2015 01:03:56 +0000
Content-Disposition: inline
In-Reply-To: <54E68512.6070108@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 04:51:30PM -0800, roopa wrote:
> >
> >Not sure yet what to do about setting the fdb aging time. I don't see a
> >mechanism to do that. No idea how important that is.
> rocker, the only consumer today relies on the bridge driver aging of learnt
> entries.
> You could do the same.
> 

Remember that we are dealing with hardware switch chips. Those chips
won't time out fdb entries just because the kernel's bridge driver
thinks that it should.

Am I missing something ?

Guenter
