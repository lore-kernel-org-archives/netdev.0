From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: correct typo in call to
 unregister_netdevice_queue
Date: Mon, 18 May 2015 16:59:41 -0400 (EDT)
Message-ID: <20150518.165941.65628962518379011.davem@davemloft.net>
References: <1431971484-23467-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60273 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbbERU7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 16:59:43 -0400
In-Reply-To: <1431971484-23467-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 18 May 2015 13:51:24 -0400

> By inspection, this appears to be a typo.  The gating comparison
> involves vxlan->dev rather than dev.  In fact, dev is the iterator in
> the preceding loop above but it is actually constant in the 2nd loop.
> 
> Use of dev seems to be a bad cut-n-paste from the prior call to
> unregister_netdevice_queue.  Change dev to vxlan->dev, since that is
> what is actually being checked.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Indeed, your fix looks correct to me.

Applied, thanks John.
