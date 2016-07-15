From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: amd: au1000_eth: use phydev from
 struct net_device
Date: Fri, 15 Jul 2016 16:44:08 -0700 (PDT)
Message-ID: <20160715.164408.306880138054467822.davem@davemloft.net>
References: <1468577112-7884-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, manuel.lauss@gmail.com,
	mugunthanvnm@ti.com, ivecera@redhat.com, xypron.glpk@gmx.de,
	netdev@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbcGOXoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:44:09 -0400
In-Reply-To: <1468577112-7884-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 15 Jul 2016 12:05:11 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
