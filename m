From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Fri, 30 Aug 2013 17:59:09 -0400 (EDT)
Message-ID: <20130830.175909.1743525148095642605.davem@davemloft.net>
References: <1377837325-5232-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, l.stach@pengutronix.de
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756017Ab3H3V7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:59:11 -0400
In-Reply-To: <1377837325-5232-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>
Date: Fri, 30 Aug 2013 12:35:25 +0800

> When the current BD is the first BD, the previous BD entry
> must be the last BD, not "bdp - 1".
> 
> Add BD entry check to get the previous BD entry correctly.
> 
> Signed-off-by: Fugang Duan  <B38611@freescale.com>

The correct fix is to put this logic into fec_enet_get_prevdesc().
With this current limitation, the function is completely useless.
