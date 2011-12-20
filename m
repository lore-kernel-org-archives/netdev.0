From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4_en: FIX: Setting default_qpn before
 using it
Date: Tue, 20 Dec 2011 13:44:28 -0500 (EST)
Message-ID: <20111220.134428.1591018074971951643.davem@davemloft.net>
References: <4EF03F02.4010904@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab1LTSoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 13:44:34 -0500
In-Reply-To: <4EF03F02.4010904@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 20 Dec 2011 09:53:38 +0200

> From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> 
> When UDP RSS is enabled, we use same QPN for TCP and UDP ranges
> The bug is that the default_qpn was used base UDP qpn before it
> was set.
> Fixes bug introduced in commit: 1202d460b1df3a77fda66f4ba5f90ae3527dd42f
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
