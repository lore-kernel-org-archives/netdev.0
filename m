From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: nb8800: use phydev from struct
 net_device
Date: Sun, 19 Jun 2016 10:55:49 -0700 (PDT)
Message-ID: <20160619.105549.1874287483015335944.davem@davemloft.net>
References: <1466284615-7045-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mans@mansr.com, sf84@laposte.net, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbcFSRzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 13:55:51 -0400
In-Reply-To: <1466284615-7045-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 18 Jun 2016 23:16:54 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
