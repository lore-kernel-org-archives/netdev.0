From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: Fix 64-bits register writes
Date: Wed, 09 Sep 2015 14:14:45 -0700 (PDT)
Message-ID: <20150909.141445.715218248884271943.davem@davemloft.net>
References: <1441768001-25318-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755674AbbIIVOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 17:14:46 -0400
In-Reply-To: <1441768001-25318-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  8 Sep 2015 20:06:41 -0700

> The macro to write 64-bits quantities to the 32-bits register swapped
> the value and offsets arguments, we want to preserve the ordering of the
> arguments with respect to how writel() is implemented for instance:
> value first, offset/base second.
> 
> Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> David,
> 
> Can you also queue this one for -stable? Thanks!

Applied and queued up for -stable, thanks.
