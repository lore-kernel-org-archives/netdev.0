From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 8/8] net: dsa: mv88e6xxx: fail on mismatching
 probe
Date: Thu, 9 Jun 2016 04:21:49 +0200
Message-ID: <20160609022149.GF2227@lunn.ch>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
 <20160609004456.5441-9-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39435 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751949AbcFICVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 22:21:51 -0400
Content-Disposition: inline
In-Reply-To: <20160609004456.5441-9-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 08, 2016 at 08:44:56PM -0400, Vivien Didelot wrote:
> Now that we have access at probe time to the chip info described in the
> device tree, check if the probed device matches the device node,
> otherwise warn the user and fail.

What good is this? So what if the device tree says a different
model. We don't care, we don't use that information at all, we read it
from the device itself.

The only thing that might make sense to check is the number of ports
in device tree against what we know the switch has. I don't think we
currently do this. But that actually requires a new method in the
driver structure, so the core can ask the driver after probe how many
ports it has.

       Andrew
