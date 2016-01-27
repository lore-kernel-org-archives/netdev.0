From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 2/2] DT: phy.txt: Clarify expected compatible values
Date: Wed, 27 Jan 2016 02:06:38 +0100
Message-ID: <20160127010638.GA4815@lunn.ch>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
 <1453853499-11248-3-git-send-email-andrew@lunn.ch>
 <56A81047.4010802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, aaro.koskinen@nokia.com,
	olof@lixom.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43375 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbcA0BGk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 20:06:40 -0500
Content-Disposition: inline
In-Reply-To: <56A81047.4010802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 26, 2016 at 04:33:11PM -0800, Florian Fainelli wrote:
> On 26/01/16 16:11, Andrew Lunn wrote:
> > PHY devices may only list clause 22, 45, and their PHY identifier
> > values as compatible values. No other compatible strings are allowed.
> > Make this clear in the documentation, and remove examples where
> > make/model compatible strings are listed.
> 
> Humm, should not we rather require Ethernet PHY Device Tree nodes to
> have *at least* a "ethernet-phy-ieee802.3-c22" or
> "ethernet-phy-ieee802.3-c45", and any other compatible string which
> further specifies the hardware is also welcome?

At the moment, "ethernet-phy-ieee802.3-c45" is used, we look for it
and act upon it. "ethernet-phy-ieee802.3-c22" is not used anywhere,
other than my new of_mdiobus_child_is_phy(). Also, for backwards
compatibility with older blobs, we can never assume one or the other
will be present.

So you are suggesting we change around 200 ethphy nodes to add in
"ethernet-phy-ieee802.3-c22", yet we don't actually do anything with
it?

  Andrew
