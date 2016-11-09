From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bgmac: fix reversed checks for clock control
 flag
Date: Wed, 09 Nov 2016 13:32:42 -0500 (EST)
Message-ID: <20161109.133242.427186215971765834.davem@davemloft.net>
References: <20161107125327.5375-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com, rafal@milecki.pl,
        jon.mason@broadcom.com
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753972AbcKISco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:32:44 -0500
In-Reply-To: <20161107125327.5375-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafa©© Mi©©ecki <zajec5@gmail.com>
Date: Mon,  7 Nov 2016 13:53:27 +0100

> From: Rafa©© Mi©©ecki <rafal@milecki.pl>
> 
> This fixes regression introduced by patch adding feature flags. It was
> already reported and patch followed (it got accepted) but it appears it
> was incorrect. Instead of fixing reversed condition it broke a good one.
> 
> This patch was verified to actually fix SoC hanges caused by bgmac on
> BCM47186B0.
> 
> Fixes: db791eb2970b ("net: ethernet: bgmac: convert to feature flags")
> Fixes: 4af1474e6198 ("net: bgmac: Fix errant feature flag check")
> Cc: Jon Mason <jon.mason@broadcom.com>
> Signed-off-by: Rafa©© Mi©©ecki <rafal@milecki.pl>

Applied.
