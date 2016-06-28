From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: r6040: use phydev from struct
 net_device
Date: Tue, 28 Jun 2016 09:15:09 -0400 (EDT)
Message-ID: <20160628.091509.1088139419997074162.davem@davemloft.net>
References: <1466881742-13414-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382AbcF1NPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 09:15:38 -0400
In-Reply-To: <1466881742-13414-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 25 Jun 2016 21:09:01 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
