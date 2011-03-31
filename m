From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Fixing use after free
Date: Thu, 31 Mar 2011 02:52:28 -0700 (PDT)
Message-ID: <20110331.025228.104048785.davem@davemloft.net>
References: <4D944954.9000701@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, error27@gmail.com
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55115
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752884Ab1CaJxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 05:53:06 -0400
In-Reply-To: <4D944954.9000701@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 31 Mar 2011 11:28:52 +0200

> 
> In case of allocation failure, tried to use the promiscuous QP
> entry that was previously freed.
> Now freeing this entry only in case we will not put it back to the list
> of promiscuous entries.
> 
> Reported-by: Dan Carpenter <error27@gmail.com>
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
