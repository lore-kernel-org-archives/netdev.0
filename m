From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/8] net: dsa: mv88e6xxx: explicit compatible
 devices
Date: Thu, 9 Jun 2016 04:14:15 +0200
Message-ID: <20160609021415.GE2227@lunn.ch>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
 <20160609004456.5441-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39429 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710AbcFICOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 22:14:19 -0400
Content-Disposition: inline
In-Reply-To: <20160609004456.5441-8-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 08, 2016 at 08:44:55PM -0400, Vivien Didelot wrote:
> Thanks to the new device probing, we can explicit the exact switch model
> in the device tree.
> 
> Name the driver "mv88e6xxx" and list all its compatible supported chips.

No. This goes against the usual way of doing device tree compatible
strings. As far as probing goes, all the currently supported switches
are compatible with 6095. We can at run time determine the specific
switch model. This list is just a pain to managed, and has no value.

We only need to add a new compatible string when we cannot determine
at probe time what a switch model is, or we need to read the ID
register in a different way.

	 Andrew
