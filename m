From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: pasemi_mac: use phydev from struct
 net_device
Date: Fri, 15 Jul 2016 16:43:27 -0700 (PDT)
Message-ID: <20160715.164327.986349475792176893.davem@davemloft.net>
References: <1468532693-456-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbcGOXn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:43:28 -0400
In-Reply-To: <1468532693-456-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 14 Jul 2016 23:44:52 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phy in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
