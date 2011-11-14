From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Fix V2] mlx4_en: Remove FCS bytes from packet length.
Date: Mon, 14 Nov 2011 14:26:01 -0500 (EST)
Message-ID: <20111114.142601.1383686913411877085.davem@davemloft.net>
References: <4EC1446D.4020209@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44321 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955Ab1KNT0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:26:16 -0500
In-Reply-To: <4EC1446D.4020209@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 14 Nov 2011 18:40:13 +0200

> When HW doesn't remove FCS bytes they are reported in the completion
> byte count, we don't need to take them to skb.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
