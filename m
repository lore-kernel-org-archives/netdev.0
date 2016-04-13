From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] DSA refactoring: set 1
Date: Wed, 13 Apr 2016 18:15:49 -0400 (EDT)
Message-ID: <20160413.181549.1087686621640300288.davem@davemloft.net>
References: <1460508045-20254-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbcDMWPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 18:15:52 -0400
In-Reply-To: <1460508045-20254-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 13 Apr 2016 02:40:38 +0200

> There has been a long running effort to refractor DSA probing to make
> the switches true linux devices. Here are a small collection of
> patches moving in this direction. Most have been seen before.
> 
> We take a little step forward by passing the dsa device point to the
> driver, thus allowing it to perform resource allocations using the
> normal mechanisms. This device structure will later be replaced by the
> devices own device structure.
> 
> Future patches will add a true driver probe function, so we rename the
> current probe function, cleaning up the namespace.
> 
> phys_port_mask continually confuses me, thinking it is about PHYs. But
> it is actually about ports enabled to the outside world. So rename it to
> enabled_port_mask.
> 
> Lots more patches yet to follow, this is just doing some ground work.
> 
> v2:
>   enabled_port_mask instread of user_port_masks
>   Added Tested-by's and Reviewed-by.

Series applied, thanks.
