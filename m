From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 1/2] net: ethoc: Fix early error paths
Date: Mon, 11 Jul 2016 19:11:43 +0200
Message-ID: <20160711171143.GB8540@lunn.ch>
References: <1468256651-15896-1-git-send-email-f.fainelli@gmail.com>
 <1468256651-15896-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jcmvbkbc@gmail.com,
	colin.king@canonical.com, tklauser@distanz.ch,
	thierry.reding@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40242 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932315AbcGKRLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 13:11:47 -0400
Content-Disposition: inline
In-Reply-To: <1468256651-15896-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 10:04:10AM -0700, Florian Fainelli wrote:
> In case any operation fails before we can successfully go the point
> where we would register a MDIO bus, we would be going to an error label
> which involves unregistering then freeing this yet to be created MDIO
> bus. Update all error paths to go to label free which is the only one
> valid until either the clock is enabled, or the MDIO bus is allocated
> and registered. This fixes kernel panics such as this one:
> 
> Fixes: a1702857724f ("net: Add support for the OpenCores 10/100 Mbps Ethernet MAC.")

Hi Florian

Did you intend to paste a panic here?

    Andrew
