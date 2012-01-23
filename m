From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] dsa: Add reporting of silicon revision for Marvell
 88E6123/88E6161/88E6165 switches.
Date: Mon, 23 Jan 2012 19:35:32 +0000
Message-ID: <1327347332.2438.1.camel@bwh-desktop>
References: <1327303254-28573-1-git-send-email-cphealy@gmail.com>
	 <4F1D2CDA.9050107@openwrt.org>
	 <20120123.135940.341602114077968006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <florian@openwrt.org>, <cphealy@gmail.com>, <ben@decadent.org.uk>,
	<buytenh@wantstofly.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31883 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753647Ab2AWTfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 14:35:40 -0500
In-Reply-To: <20120123.135940.341602114077968006.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-23 at 13:59 -0500, David Miller wrote:
> From: Florian Fainelli <florian@openwrt.org>
> Date: Mon, 23 Jan 2012 10:48:10 +0100
> 
> > On 01/23/12 08:20, Chris Healy wrote:
> >> +		if ((ret&  0xfff0) == 0x1650)
> >>   			return "Marvell 88E6165";
> >>   	}
> > 
> > What about a switch/case here?
> 
> I don't think you can express "(ret&  0xfff0) == 0x1650)" using
> a switch statement.
> 
> But BTW, the formatting of that expression needs to be cleaned up.
> It should be "(ret & 0xfff0) == 0x1650)"

Florian's mailer has mangled the quoted text; the original patch had
correct spacing.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
