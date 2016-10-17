From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ila: Don't use dest cache when gateway is set
Date: Mon, 17 Oct 2016 10:30:51 -0400 (EDT)
Message-ID: <20161017.103051.222981655806556402.davem@davemloft.net>
References: <20161017042535.2167680-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757558AbcJQOax (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:30:53 -0400
In-Reply-To: <20161017042535.2167680-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Sun, 16 Oct 2016 21:25:35 -0700

> If the gateway is set on an ILA route we don't need to bother with using
> the destination cache in the ILA route. Translation does not change the
> routing in this case so we can stick with orig_output in the lwstate
> output function.
> 
> Tested: Ran netperf with and without gateway for LWT route.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied, thanks Tom.
