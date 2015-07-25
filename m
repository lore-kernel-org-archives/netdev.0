From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] dsa: mv88e6352/mv88e6xxx: Move temperature sensor code
 to mv88e6xxx.c
Date: Sat, 25 Jul 2015 20:46:52 +0200
Message-ID: <20150725184652.GB604@lunn.ch>
References: <1437842548-7233-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47451 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932104AbbGYSxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jul 2015 14:53:39 -0400
Content-Disposition: inline
In-Reply-To: <1437842548-7233-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 25, 2015 at 09:42:28AM -0700, Guenter Roeck wrote:
> Move the temperature sensing code for mv88e6352 and mv88e6320 families
> into mv88e6xxx.c to simplify adding support for additional chips.
> 
> With this change, mv88e6xxx_6320_family() no longer needs to be
> a global function and is made static.
> 
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks for doing this Guenter

       Andrew
