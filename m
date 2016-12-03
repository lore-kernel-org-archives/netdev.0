From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: remove EFX_BUG_ON_PARANOID, use
 EFX_WARN_ON_[ONCE_]PARANOID instead
Date: Sat, 03 Dec 2016 16:11:24 -0500 (EST)
Message-ID: <20161203.161124.670604606383689626.davem@davemloft.net>
References: <9435baa4-b9b5-955e-eac2-3106feb87136@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, bkenward@solarflare.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750976AbcLCVTh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 16:19:37 -0500
In-Reply-To: <9435baa4-b9b5-955e-eac2-3106feb87136@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 2 Dec 2016 15:51:33 +0000

> Logically, EFX_BUG_ON_PARANOID can never be correct.  For, BUG_ON should
>  only be used if it is not possible to continue without potential harm;
>  and since the non-DEBUG driver will continue regardless (as the BUG_ON is
>  compiled out), clearly the BUG_ON cannot be needed in the DEBUG driver.
> So, replace every EFX_BUG_ON_PARANOID with either an EFX_WARN_ON_PARANOID
>  or the newly defined EFX_WARN_ON_ONCE_PARANOID.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied.
