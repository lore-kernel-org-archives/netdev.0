From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] net: phy: add
 phy_ethtool_{get|set}_link_ksettings
Date: Tue, 10 May 2016 15:06:35 -0400 (EDT)
Message-ID: <20160510.150635.1790167175449484829.davem@davemloft.net>
References: <1462832383-25541-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, f.fainelli@gmail.com, decot@googlers.com,
	ben@decadent.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbcEJTGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 15:06:37 -0400
In-Reply-To: <1462832383-25541-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 10 May 2016 00:19:40 +0200

> Ethtool callbacks {get|set}_link_ksettings may be the
> same for many drivers. So we add two generics callbacks
> phy_ethtool_{get|set}_link_ksettings.
> 
> To use those generics callbacks, the ethernet driver must
> use the pointer phydev contained in struct net_device, and
> not use a private structure to store this pointer.

Series applied, thanks.
