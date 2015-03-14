From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: do not use slave MII bus for fixed
 PHYs
Date: Sat, 14 Mar 2015 19:17:09 -0400 (EDT)
Message-ID: <20150314.191709.193087365337267305.davem@davemloft.net>
References: <1426364519-13465-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbbCNXRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 19:17:11 -0400
In-Reply-To: <1426364519-13465-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 14 Mar 2015 13:21:59 -0700

> Commit cd28a1a9baee7 ("net: dsa: fully divert PHY reads/writes if
> requested") introduced a check for particular PHYs that need to be
> accessed using the slave MII bus created by DSA, but this check was too
> inclusive. This would prevent fixed PHYs from being successfully
> registered because those should not go through the slave MII bus created
> by DSA.
> 
> Make sure we check that the PHY is not a fixed PHY to prevent that from
> happening.
> 
> Fixes: cd28a1a9baee7 ("net: dsa: fully divert PHY reads/writes if requested")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Hi David,
> 
> This change is only in net-next for now, thanks!

Applied, thanks.
