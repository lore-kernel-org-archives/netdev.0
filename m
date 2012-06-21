From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] Fix unexpected SA hard expiration after
 changing date
Date: Wed, 20 Jun 2012 21:06:49 -0700 (PDT)
Message-ID: <20120620.210649.1599003525640605191.davem@davemloft.net>
References: <1340092269-6136-1-git-send-email-fan.du@windriver.com>
	<1340092269-6136-2-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org,
	fdu@windriver.com
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab2FUEGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 00:06:50 -0400
In-Reply-To: <1340092269-6136-2-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "fan.du" <fan.du@windriver.com>
Date: Tue, 19 Jun 2012 15:51:09 +0800

> +			x->xflags |= ~XFRM_SOFT_EXPIRE;

This is not how you clear a bit in a bitmask.
