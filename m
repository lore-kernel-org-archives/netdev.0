From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] ila: Precompute checksums
Date: Sun, 23 Aug 2015 20:38:43 -0700 (PDT)
Message-ID: <20150823.203843.1007208746644126304.davem@davemloft.net>
References: <1440094958-1808151-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbHXDio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 23:38:44 -0400
In-Reply-To: <1440094958-1808151-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 20 Aug 2015 11:22:36 -0700

> This patch set:
>  - Adds argument ot LWT build_state that holds a pointer to the fib
>    configuration being applied to the new route
>  - Adds support in ILA to precompute checksum difference for
>    performance optimization
> 
> v2:
>  Move return argument in build_state to end of arguments

Series applied, thanks Tom.

We really need to think about early-demux and netfilter a bit more
wrt. ILA.
