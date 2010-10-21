From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] drivers/net/ax88796.c: Return error code in failure
Date: Thu, 21 Oct 2010 04:31:00 -0700 (PDT)
Message-ID: <20101021.043100.42796935.davem@davemloft.net>
References: <1287411074-19825-2-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: p_gortmaker@yahoo.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43512
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757633Ab0JULai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:30:38 -0400
In-Reply-To: <1287411074-19825-2-git-send-email-julia@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Mon, 18 Oct 2010 16:11:14 +0200

> In this code, 0 is returned on failure, even though other
> failures return -ENOMEM or other similar values.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
