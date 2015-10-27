From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 route: Use flag instead of calling
 fib6_get_table() twice
Date: Mon, 26 Oct 2015 22:05:14 -0700 (PDT)
Message-ID: <20151026.220514.248571981890692553.davem@davemloft.net>
References: <562C418B.9050909@gmail.com>
	<1445741067-14891-1-git-send-email-masashi.honma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: masashi.honma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180AbbJ0Esf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 00:48:35 -0400
In-Reply-To: <1445741067-14891-1-git-send-email-masashi.honma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masashi Honma <masashi.honma@gmail.com>
Date: Sun, 25 Oct 2015 11:44:27 +0900

> The fib6_get_table() is called twice to show the warning.
> This patch reduces calling the function.
> 
> Signed-off-by: Masashi Honma <masashi.honma@gmail.com>

I think the added cost of passing a reference to an on-stack variable
exceeds the value of whatever you think you are improving here.

The code as-is is fine as far as I'm concerned.
