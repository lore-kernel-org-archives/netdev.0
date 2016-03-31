From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] net: dsa: mv88e6xxx: Clear the PDOWN
 bit on setup
Date: Thu, 31 Mar 2016 15:13:26 -0400 (EDT)
Message-ID: <20160331.151326.1811698418230235797.davem@davemloft.net>
References: <1459301981-26535-1-git-send-email-patrick@puiterwijk.org>
	<1459301981-26535-2-git-send-email-patrick@puiterwijk.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, netdev@vger.kernel.org, dennis@ausil.us,
	pbrobinson@gmail.com
To: patrick@puiterwijk.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57547 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756197AbcCaTN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 15:13:28 -0400
In-Reply-To: <1459301981-26535-2-git-send-email-patrick@puiterwijk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Uiterwijk <patrick@puiterwijk.org>
Date: Wed, 30 Mar 2016 01:39:41 +0000

> Some of the vendor-specific bootloaders set up this part
> of the initialization for us, so this was never added.
> However, since upstream bootloaders don't initialize the
> chip specifically, they leave the fiber MII's PDOWN flag
> set, which means that the CPU port doesn't connect.
> 
> This patch checks whether this flag has been clear prior
> by something else, and if not make us clear it.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Patrick Uiterwijk <patrick@puiterwijk.org>

Applied, thank you.
