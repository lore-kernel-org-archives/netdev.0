From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: Report "persist" flag to userspace
Date: Wed, 12 Jun 2013 15:07:44 -0700 (PDT)
Message-ID: <20130612.150744.527671463418307561.davem@davemloft.net>
References: <51B6FED4.6090703@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756858Ab3FLWHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 18:07:45 -0400
In-Reply-To: <51B6FED4.6090703@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Tue, 11 Jun 2013 14:41:24 +0400

> The TUN_PERSIST flag is not reported at all -- both TUNGETIFF, and sysfs
> "flags" attribute skip one. Knowing whether a device is persistent or not
> is critical for checkpoint-restore, thus I propose to add the read-only
> IFF_PERSIST one for this.
> 
> Setting this new IFF_PERSIST is hardly possible, as TUNSETIFF doesn't check
> for unknown flags being zero and thus there can be trash.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied, thanks.
