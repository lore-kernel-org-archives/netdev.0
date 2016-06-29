From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: mvpp2: use phydev from struct
 net_device
Date: Wed, 29 Jun 2016 06:04:21 -0400 (EDT)
Message-ID: <20160629.060421.33538511106611198.davem@davemloft.net>
References: <1467065292-20996-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mw@semihalf.com, jszhang@marvell.com, amitoj1606@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbcF2KEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 06:04:53 -0400
In-Reply-To: <1467065292-20996-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Tue, 28 Jun 2016 00:08:11 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
