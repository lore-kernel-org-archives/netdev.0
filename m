From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] flow_dissector: Fix function argument
 ordering dependency
Date: Tue, 01 Sep 2015 20:20:14 -0700 (PDT)
Message-ID: <20150901.202014.1478743234631968185.davem@davemloft.net>
References: <1441156264-38469-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbbIBDUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 23:20:15 -0400
In-Reply-To: <1441156264-38469-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 1 Sep 2015 18:11:04 -0700

> Commit c6cc1ca7f4d70c ("flowi: Abstract out functions to get flow hash
> based on flowi") introduced a bug in __skb_set_sw_hash where we
> require a dependency on evaluating arguments in a function in order.
> There is no such ordering enforced in C, so this incorrect. This
> patch fixes that by splitting out the arguments. This bug was
> found via a compiler warning that keys may be uninitialized.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied.
