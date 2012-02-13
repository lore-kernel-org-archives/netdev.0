From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] NET: PHY names vs MDIO bus names regression fixes
Date: Mon, 13 Feb 2012 16:02:04 -0500 (EST)
Message-ID: <20120213.160204.622185887026096350.davem@davemloft.net>
References: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173Ab2BMVCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 16:02:10 -0500
In-Reply-To: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Mon, 13 Feb 2012 12:23:19 +0100

> This patch serie aims at fixing the regressions introduced with the
> "use an unique MDIO bus name" patchset. Some drivers still formatted
> the PHY id to use the old bus name (e.g: "0" or "1") and therefore
> the PHY probing logic gets broken because their underlying MDIO bus
> name was changed too from "0" to <foo>-<id>.
> 
> The offending patches got introduced during 3.3-rc1.

Then why the heck are you CC:'ing -stable on these patches?

We're still in the 3.3-rcX phase, so there is no other tree in
the world these patches should be applied to.

In any event, for networking stuff, you shouldn't be adding
the stable CC: anyways, I take care of all networking stable
submissions myself.
