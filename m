From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] mlx4_en: Fix error handling while activating RX
 rings
Date: Tue, 21 Apr 2009 01:49:51 -0700 (PDT)
Message-ID: <20090421.014951.238255637.davem@davemloft.net>
References: <49EC859C.700@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43166
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754481AbZDUIt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:49:59 -0400
In-Reply-To: <49EC859C.700@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 20 Apr 2009 17:24:28 +0300

> In case of failure of either srq creation or page allocation,
> the cleanup code handled the failed ring as well, and tried
> to destroy resources that where not allocated.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
