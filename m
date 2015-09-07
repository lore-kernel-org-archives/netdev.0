From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fixed_phy: pass 'irq' to fixed_phy_add()
Date: Sun, 06 Sep 2015 23:49:48 -0700 (PDT)
Message-ID: <20150906.234948.490398330420454086.davem@davemloft.net>
References: <3613326.r1qXWqo08b@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbbIGGtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 02:49:49 -0400
In-Reply-To: <3613326.r1qXWqo08b@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 03 Sep 2015 23:22:16 +0300

> I've noticed  that fixed_phy_register() ignores its 'irq' parameter instead of
> passing it to fixed_phy_add(). Luckily, fixed_phy_register()  seems to  always
> be  called with PHY_POLL  for 'irq'... :-)
> 
> Fixes: a75951217472 ("net: phy: extend fixed driver with fixed_phy_register()")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
