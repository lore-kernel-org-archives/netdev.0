From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 3/4] net: dsa: Suffix function manipulating
 device_node with _dn
Date: Wed, 6 Jul 2016 00:52:03 +0200
Message-ID: <20160705225203.GE28825@lunn.ch>
References: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
 <1467756433-25062-4-git-send-email-f.fainelli@gmail.com>
 <20160705223612.GC28825@lunn.ch>
 <577C3817.1070908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36533 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877AbcGEWwH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 18:52:07 -0400
Content-Disposition: inline
In-Reply-To: <577C3817.1070908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That is true for the devices I know about, both in and out of tree,
> however, while discussing offline with Vivien it seemed like there was a
> potential need for having a x86-based platform which could need that,
> Vivien do you think this platform could be in-tree one day (if not already)?

x86 can do device tree. And if it is a complex board, it probably
needs more of the device tree features like fixed-phys, phy-mode,
devlink when it lands, etc.

If this board really does come to mainline, we should consider support
for it, one way or the other, but until then, i prefer KISS.

   Andrew
