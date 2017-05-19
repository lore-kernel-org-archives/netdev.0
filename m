From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: warn on negative reordering values
Date: Fri, 19 May 2017 16:56:23 -0400 (EDT)
Message-ID: <20170519.165623.1073497552473620871.davem@davemloft.net>
References: <20170516213903.78909-1-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, ncardwell@google.com,
        ycheng@google.com, edumazet@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57502 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756801AbdESU4Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 16:56:25 -0400
In-Reply-To: <20170516213903.78909-1-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Tue, 16 May 2017 17:39:02 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Commit bafbb9c73241 ("tcp: eliminate negative reordering
> in tcp_clean_rtx_queue") fixes an issue for negative
> reordering metrics.
> 
> To be resilient to such errors, warn and return
> when a negative metric is passed to tcp_update_reordering().
> 
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
