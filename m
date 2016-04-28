From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: avoid some atomic ops when FASYNC is
 not used
Date: Wed, 27 Apr 2016 23:10:08 -0400 (EDT)
Message-ID: <20160427.231008.616243718482885421.davem@davemloft.net>
References: <1461605974-4242-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710AbcD1DKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 23:10:11 -0400
In-Reply-To: <1461605974-4242-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 25 Apr 2016 10:39:31 -0700

> We can avoid some atomic operations on sockets not using FASYNC

I guess a user can do weird things and set/clear the FASYNC bit in the
middle of the SOCKWQ_ASYNC_ bit being set, and reset the FASYNC bit
later and the SOCKWQ_* state is stale.

However, that's probably not worth handling explicitly.

Series applied, thanks.
