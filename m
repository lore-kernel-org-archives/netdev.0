From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] drivers/net/wan: introduce missing kfree
Date: Fri, 11 Sep 2009 12:13:31 -0700 (PDT)
Message-ID: <20090911.121331.60080960.davem@davemloft.net>
References: <Pine.LNX.4.64.0909111821360.10552@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752786AbZIKTNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:13:15 -0400
In-Reply-To: <Pine.LNX.4.64.0909111821360.10552@pc-004.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Fri, 11 Sep 2009 18:21:51 +0200 (CEST)

> Error handling code following a kmalloc should free the allocated data.
> 
> The semantic match that finds the problem is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
