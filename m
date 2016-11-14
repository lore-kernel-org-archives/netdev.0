From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 3/5] ethtool: (uapi) Add
 ETHTOOL_PHY_DOWNSHIFT to PHY tunables
Date: Mon, 14 Nov 2016 14:42:15 +0100
Message-ID: <20161114134215.GI26710@lunn.ch>
References: <1479115760-1182-1-git-send-email-allan.nielsen@microsemi.com>
 <1479115760-1182-4-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37840 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752824AbcKNNmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 08:42:16 -0500
Content-Disposition: inline
In-Reply-To: <1479115760-1182-4-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 10:29:18AM +0100, Allan W. Nielsen wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> For operation in cabling environments that are incompatible with
> 1000BAST-T, PHY device may provide an automatic link speed downshift
> operation. When enabled, the device automatically changes its 1000BAST-T
> auto-negotiation to the next slower speed after a configured number of
> failed attempts at 1000BAST-T.  This feature is useful in setting up in
> networks using older cable installations that include only pairs A and B,
> and not pairs C and D.

Hi Allan

A nitpick:

s/BAST/BASE/g

Otherwise, this is good.

	   Andrew
