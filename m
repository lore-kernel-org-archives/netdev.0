From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] vlan: turn on unicast filtering on vlan device
Date: Sun, 21 Feb 2016 21:54:33 -0500 (EST)
Message-ID: <20160221.215433.1741977191142448096.davem@davemloft.net>
References: <1455789611-31803-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939AbcBVCyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 21:54:35 -0500
In-Reply-To: <1455789611-31803-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Thu, 18 Feb 2016 10:00:11 +0000

> Currently vlan device inherits unicast filtering flag from underlying
> device. If underlying device doesn't support unicast filter, this will
> put vlan device into promiscuous mode when it's stacked.
> 
> Tun on IFF_UNICAST_FLT on the vlan device in any case so that it does
> not go into promiscuous mode needlessly. If underlying device does not
> support unicast filtering, that device will enter promiscuous mode.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thanks.
