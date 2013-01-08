From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1 net-next] net: fec: enable pause frame to improve rx
 prefomance for 1G network
Date: Tue, 8 Jan 2013 13:57:27 +0000
Message-ID: <1357653447.29986.15.camel@deadeye.wl.decadent.org.uk>
References: <1357634609-4112-1-git-send-email-Frank.Li@freescale.com>
	 <1357649564.29986.10.camel@deadeye.wl.decadent.org.uk>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7104@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Frank Li <Frank.Li@freescale.com>, <lznuaa@gmail.com>,
	<shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <s.hauer@pengutronix.de>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20788 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756181Ab3AHN5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 08:57:32 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7104@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-08 at 13:32 +0000, David Laight wrote:
> > If the medium supports autoneog, use mii_advertise_flowctrl() in
> > set_pauseparam to update pause frame advertising and then restart
> > autoneg.
> 
> Isn't autoneg continuous?
> In which case you just need to monitor the response register.
> Monitoring MII registers is usually a complete PITA though
> (due to the requirements for delays during the bit-bashing).

AIUI you have to break the link before renegotiating.  So you should
only need to read autoneg results after a PHY interrupt or polling for a
link change.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
