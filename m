From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net-next 0/3] Ethtool support for phy stats
Date: Sun, 27 Dec 2015 21:12:23 +0100
Message-ID: <20151227201223.GA24712@lunn.ch>
References: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
 <EEE79716-61A1-403E-826D-198C21667070@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50921 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872AbbL0UMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2015 15:12:25 -0500
Content-Disposition: inline
In-Reply-To: <EEE79716-61A1-403E-826D-198C21667070@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 27, 2015 at 12:07:15PM -0800, Florian Fainelli wrote:
> On December 27, 2015 3:58:25 AM PST, Andrew Lunn <andrew@lunn.ch> wrote:
> >This patchset add ethtool support for reading statistics from the PHY.
> >The Marvell and Micrel Phys are then extended to report receiver
> >packet errors and idle errors.
> 
> Reviewed-by: Florian Fainelli <f.faibelli@gmail.com>
> 

> This is very useful, thanks! I like that you have introduced a
> separate interface rather than forcing the use of the existing get
> statistics method and then overlaying PHY stats to the existing MAC
> stats, this is just cleaner.

I started out by extending the MAC stats, but the code was ugly
dealing with the different cases and MAC and PHY statistics. This way
is a lot cleaner.

   Andrew
