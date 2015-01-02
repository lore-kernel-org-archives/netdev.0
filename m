From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] net: cpsw: fix hangs and improve IRQ handling
Date: Fri, 02 Jan 2015 16:45:36 -0500 (EST)
Message-ID: <20150102.164536.1906626949656646358.davem@davemloft.net>
References: <1420222228-31949-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, yegorslists@googlemail.com,
	linux-omap@vger.kernel.org, netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180AbbABVpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:45:39 -0500
In-Reply-To: <1420222228-31949-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Fri, 2 Jan 2015 12:10:24 -0600

> In any case, patch 1 should go in during the -rc an get backported
> all the way back to v3.9, while the other patches can (should) be
> delayed for v3.20 merge window.

If that's what you want, the way you submitted these changes it not
the correct way to do it.

You should instead submit patch #1 all by itself, correctly targetting
'net'.

Then, after the next time I merge 'net' into 'net-next', you can submit
the rest of the changes.
