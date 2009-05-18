From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: Fix not deleted napi structures
Date: Sun, 17 May 2009 20:49:21 -0700 (PDT)
Message-ID: <20090517.204921.23854924.davem@davemloft.net>
References: <49EC859C.700@mellanox.co.il>
	<4A0AB34A.10100@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755373AbZERDtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 23:49:23 -0400
In-Reply-To: <4A0AB34A.10100@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Wed, 13 May 2009 14:47:22 +0300

> Napi structures are being created each time we open a port, but when
> the port is closed the napi structure is only disabled but not removed.
> This bug caused hang while removing the driver.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied, thanks!
