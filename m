From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: Fix cleanup if workqueue create in
 mlx4_en_add() fails
Date: Tue, 21 Apr 2009 01:50:18 -0700 (PDT)
Message-ID: <20090421.015018.163997666.davem@davemloft.net>
References: <49EC859C.700@mellanox.co.il>
	<49EC85FD.2080009@mellanox.co.il>
	<adavdoywrsn.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org,
	tziporet@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43182
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756142AbZDUIu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:50:26 -0400
In-Reply-To: <adavdoywrsn.fsf_-_@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 20 Apr 2009 21:32:08 -0700

> If creating a workqueue fails, don't jump to the error path where that
> same workqueue is destroyed, since destroy_workqueue() can't handle a
> NULL pointer.
> 
> This was spotted by the Coverity checker (CID 2617).
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Applied.
