From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] net: ethernet: arc: Don't free Rockchip resources
 before disconnect from phy
Date: Wed, 10 Sep 2014 13:03:26 -0700 (PDT)
Message-ID: <20140910.130326.265195308573058113.davem@davemloft.net>
References: <1410335473-23573-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko@sntech.de, linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: romain.perier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbaIJUD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 16:03:27 -0400
In-Reply-To: <1410335473-23573-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Romain Perier <romain.perier@gmail.com>
Date: Wed, 10 Sep 2014 07:51:13 +0000

> Free resources before being disconnected from phy and calling core driver is
> wrong and should not happen. It avoids a delay of 4-5s caused by the timeout of
> phy_disconnect().
> 
> Signed-off-by: Romain Perier <romain.perier@gmail.com>

Applied, thanks.
