From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv7 net-next 1/4] sunvnet: upgrade to VIO protocol
 version 1.6
Date: Mon, 29 Sep 2014 15:29:28 -0400 (EDT)
Message-ID: <20140929.152928.749693479542761839.davem@davemloft.net>
References: <54299BCD.7050807@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	Raghuram.Kothakota@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaI2T3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:29:30 -0400
In-Reply-To: <54299BCD.7050807@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Mon, 29 Sep 2014 13:50:05 -0400

> This patch upgrades the sunvnet driver to support VIO protocol version 1.6.
> In particular, it adds per-port MTU negotiation, allowing MTUs other than
> ETH_FRAMELEN with ports using newer VIO protocol versions.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Just an FYI, once I apply this series I'm going to extract the
arch/sparc parts and apply that also to the sparc-next tree in order
to deal with the pending block driver patches from Dwight Engen and
Allan Pais.
