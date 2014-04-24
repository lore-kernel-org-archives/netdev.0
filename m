From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gianfar: Check if phydev present on ethtool -A
Date: Thu, 24 Apr 2014 13:36:40 -0400 (EDT)
Message-ID: <20140424.133640.2219848793339958548.davem@davemloft.net>
References: <1398260327-23381-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756972AbaDXRgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:36:42 -0400
In-Reply-To: <1398260327-23381-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 23 Apr 2014 16:38:47 +0300

> This fixes a seg fault on 'ethtool -A' entry if the
> interface is down.  Obviously we need to have the
> phy device initialized / "connected" (see of_phy_connect())
> to be able to advertise pause frame capabilities.
> 
> Fixes: 23402bddf9e56eecb27bbd1e5467b3b79b3dbe58
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thanks Claudiu.
