From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net: tile: Use helpers from linux/etherdevice.h
 to check/set MAC
Date: Fri, 30 May 2014 17:06:56 -0700 (PDT)
Message-ID: <20140530.170656.2098254592489899285.davem@davemloft.net>
References: <1401192245-26260-1-git-send-email-tklauser@distanz.ch>
	<1401436037-4993-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432AbaEaAG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 20:06:57 -0400
In-Reply-To: <1401436037-4993-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 30 May 2014 09:47:17 +0200

> Use is_zero_ether_addr() to check for the MAC address being all zeros instead of
> open coding the check.
> 
> Also use ether_addr_copy() instead of a manual memcpy() to set the
> netdev->dev_addr.
> 
> Furthermore, get rid of a redundant assignment of netdev->addr_len. This is
> already set by ether_setup() which is called in tile_net_setup().
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>

Applied.
