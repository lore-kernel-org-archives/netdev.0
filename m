From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 13/20] net: dsa: mv88e6xxx: factorize
 GLOBAL_CONTROL setup
Date: Fri, 6 May 2016 02:55:46 +0200
Message-ID: <20160506005546.GK7972@lunn.ch>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462488064-1841-14-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58022 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753003AbcEFAzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 20:55:49 -0400
Content-Disposition: inline
In-Reply-To: <1462488064-1841-14-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 06:40:57PM -0400, Vivien Didelot wrote:
> All switch models configure the GLOBAL_CONTROL register with slightly
> differences.

And as far as i know, we have no idea why.
 
> Assume a common setup to enable the PHY Polling Unit if present, discard
> packets with excessive collisions, set the maximum frame size to 1632,
> and mask all interrupt sources.

This is a behaviour change, not just a refactor. It would be good to
say on which families it has been tested, and which have not.

    Andrew
