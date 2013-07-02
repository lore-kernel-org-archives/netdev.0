From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Swap ver and type in pppoe_hdr
Date: Mon, 01 Jul 2013 18:20:19 -0700 (PDT)
Message-ID: <20130701.182019.1224478859800012860.davem@davemloft.net>
References: <1372436151-61527-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755787Ab3GBBUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 21:20:21 -0400
In-Reply-To: <1372436151-61527-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Sat, 29 Jun 2013 00:15:51 +0800

> Ver and type in pppoe_hdr should be swapped as defined by RFC2516
> section-4.

I can't believe this has been wrong for more than 8 years.

But, of course, it is possible.  Especially since we never check these
'ver' and 'type' fields on packet input, and we always set them both
to the same value ('1') on output.

Applied, thanks.
