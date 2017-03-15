From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp
 cache
Date: Wed, 15 Mar 2017 16:45:29 -0700 (PDT)
Message-ID: <20170315.164529.1917039744356644049.davem@davemloft.net>
References: <20170315203046.158791-1-soheil.kdev@gmail.com>
        <20170315.154044.170788541865531834.davem@davemloft.net>
        <20170315225726.GA28498@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: soheil.kdev@gmail.com, netdev@vger.kernel.org, soheil@google.com,
        edumazet@google.com, ncardwell@google.com, ycheng@google.com,
        lvml@5t9.de
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdCOXqe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 19:46:34 -0400
In-Reply-To: <20170315225726.GA28498@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 15 Mar 2017 23:57:26 +0100

> AFAIU we only have two alternatives, removal of the randomization feature
> or switch to a offset computed via hash(saddr, daddr, secret).
> 
> Unless there are more comments I'll look into doing the latter tomorrow.

No, I'll apply the removal.
