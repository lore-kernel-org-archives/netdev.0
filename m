From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv6: fix ecmp lookup when oif is specified
Date: Mon, 01 Jul 2013 13:27:59 -0700 (PDT)
Message-ID: <20130701.132759.1505361202006376706.davem@davemloft.net>
References: <20130626.151929.2241949243651761177.davem@davemloft.net>
	<1372433748-2991-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203Ab3GAU17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:27:59 -0400
In-Reply-To: <1372433748-2991-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 28 Jun 2013 17:35:48 +0200

> There is no reason to skip ECMP lookup when oif is specified, but this implies
> to check oif given by user when selecting another route.
> When the new route does not match oif requirement, we simply keep the initial
> one.
> 
> Spotted-by: dingzhi <zhi.ding@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks Nicolas.
