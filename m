From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] mlx4_en: Fix partial rings feature
Date: Mon, 25 May 2009 00:36:24 -0700 (PDT)
Message-ID: <20090525.003624.199194278.davem@davemloft.net>
References: <49EC859C.700@mellanox.co.il>
	<4A0AB34A.10100@mellanox.co.il>
	<4A1948D7.8010504@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42774
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758895AbZEYHgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 03:36:25 -0400
In-Reply-To: <4A1948D7.8010504@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Sun, 24 May 2009 16:17:11 +0300

> In case of allocation failure, the actual ring size is rounded down to
> nearest power of 2. The remaining descriptors are freed.
> The CQ and SRQ are allocated with the actual size and the mask is updated.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied to net-next-2.6
