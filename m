From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: initialize the routing table
Date: Thu, 7 Jul 2016 15:24:59 +0200
Message-ID: <20160707132459.GN19800@lunn.ch>
References: <20160707000354.18217-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37818 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbcGGNZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 09:25:03 -0400
Content-Disposition: inline
In-Reply-To: <20160707000354.18217-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2016 at 08:03:54PM -0400, Vivien Didelot wrote:
> The routing table of every switch in a tree is currently initialized to
> all zeros. This is an issue since 0 is a valid port number.
> 
> Add a DSA_RTABLE_NONE=-1 constant to initialize the signed values of the
> routing table pointing to other switches.
> 
> This fixes the device mapping of the mv88e6xxx driver where the port
> pointing to the switch itself and to non-existent switches was wrongly
> configured to be 0. It is now set to the expected 0xf value.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Fixes: 4a7704ffa867 ("net: dsa: Remove dynamic allocate of routing table")

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
