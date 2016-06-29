From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: lpc_eth: use phydev from struct
 net_device
Date: Wed, 29 Jun 2016 08:18:25 -0400 (EDT)
Message-ID: <20160629.081825.239459285788245816.davem@davemloft.net>
References: <1467151185-31403-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vz@mleia.com, slemieux.tyco@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121AbcF2MSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 08:18:51 -0400
In-Reply-To: <1467151185-31403-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 28 Jun 2016 23:59:44 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
