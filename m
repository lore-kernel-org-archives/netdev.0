From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 route: Aggregate table getting code
Date: Sun, 18 Oct 2015 23:09:13 -0700 (PDT)
Message-ID: <20151018.230913.533343373986091178.davem@davemloft.net>
References: <1445129499-2496-1-git-send-email-masashi.honma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: masashi.honma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335AbbJSFwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 01:52:55 -0400
In-Reply-To: <1445129499-2496-1-git-send-email-masashi.honma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masashi Honma <masashi.honma@gmail.com>
Date: Sun, 18 Oct 2015 09:51:39 +0900

> These lines could be aggregated to one line because fib6_new_table() calls
> fib6_get_table() inside on both cases CONFIG_IPV6_MULTIPLE_TABLES is enabled or
> not.
> 
> Signed-off-by: Masashi Honma <masashi.honma@gmail.com>

This is not correct.

The whole point of the test is so that the kernel log message
warning for failing to provide NLM_F_CREATE can be printed
in precisely the correct conditions.
