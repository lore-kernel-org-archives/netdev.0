From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] fix mv643xx_eth for disabled autoneg
Date: Wed, 20 Mar 2013 12:49:08 +0100
Message-ID: <20130320114908.GA4110@orbit.nwl.cc>
References: <1362592142-4049-1-git-send-email-phil.sutter@viprinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:45257 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756676Ab3CTMAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 08:00:32 -0400
Content-Disposition: inline
In-Reply-To: <1362592142-4049-1-git-send-email-phil.sutter@viprinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 06, 2013 at 06:49:02PM +0100, Phil Sutter wrote:
> When autoneg has been disabled in the PHY (Marvell 88E1118 here), auto
> negotiation between MAC and PHY seem non-functional anymore. The only
> way I found to workaround this is to manually configure the MAC with the
> settings sent to the PHY earlier.

And still, this is somehow broken for turned off autoneg. Not a DoS
anymore, but it seems like one can not disable duplex autoneg. No matter
what duplex settings I configure on each side, communication is still
possible.

Do you have any idea what could be missing or how to furtherly track
down the problem? Could this even be a bug in the hardware?

Best wishes, Phil
