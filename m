From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] mlx4_en: use NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
 for tx csum at initialization
Date: Tue, 21 Apr 2009 01:50:07 -0700 (PDT)
Message-ID: <20090421.015007.212665308.davem@davemloft.net>
References: <49EC859C.700@mellanox.co.il>
	<49EC87AB.1070009@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755879AbZDUIuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:50:15 -0400
In-Reply-To: <49EC87AB.1070009@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 20 Apr 2009 17:33:15 +0300

> The former usage was to set the NETIF_F_HW_CSUM flag which is not used
> in get_tx_csum. It caused Ethtool to show tx checksum as "on" even
> though it was turned off in previous operation.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
