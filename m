From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] mv643xx_eth: inline txq_alloc_desc_index()
Date: Thu, 20 Nov 2008 03:59:24 -0800 (PST)
Message-ID: <20081120.035924.77428388.davem@davemloft.net>
References: <20081118222913.GU5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754758AbYKTL7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 06:59:24 -0500
In-Reply-To: <20081118222913.GU5006@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 18 Nov 2008 23:29:14 +0100

> Since txq_alloc_desc_index() is a very simple function, and since
> descriptor ring index handling for transmit reclaim, receive
> processing and receive refill is already handled inline as well,
> inline txq_alloc_desc_index() into its two call sites.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied.
