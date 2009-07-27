From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/12] drivers/net: Correct redundant test
Date: Mon, 27 Jul 2009 11:36:01 -0700 (PDT)
Message-ID: <20090727.113601.155824883.davem@davemloft.net>
References: <Pine.LNX.4.64.0907271813120.2682@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44726
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753209AbZG0Sfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 14:35:54 -0400
In-Reply-To: <Pine.LNX.4.64.0907271813120.2682@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Mon, 27 Jul 2009 18:13:30 +0200 (CEST)

> From: Julia Lawall <julia@diku.dk>
> 
> res has already been tested.  It seems that this test should be on the
> recently returned value mmio.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://www.emn.fr/x-info/coccinelle/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied to net-next-2.6
