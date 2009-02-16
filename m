From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] mv643xx_eth updates
Date: Sun, 15 Feb 2009 23:46:30 -0800 (PST)
Message-ID: <20090215.234630.202443700.davem@davemloft.net>
References: <20090213000615.GJ17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, nico@cam.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753392AbZBPHqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 02:46:46 -0500
In-Reply-To: <20090213000615.GJ17914@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Fri, 13 Feb 2009 01:06:15 +0100

> Two things here:
> - Exporting some functionality that mostly already existed in the
>   driver (interrupt coalescing, etc) to userland via ethtool.
> - Add Kconfig-configurable LRO support.

Applied to net-next-2.6, but I think making LRO support
Kconfig'able is a terrible precedent to set.

We have an ethtool knob, people can turn it off.

And furthermore, if it is worse in some cases that is
a bug that we should fix rather than ignore while hiding
behind some Kconfig option.

Please reconsider...
