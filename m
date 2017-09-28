From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-ipv6: remove unused IP6_ECN_clear() function
Date: Thu, 28 Sep 2017 10:48:57 -0700 (PDT)
Message-ID: <20170928.104857.2113645025730852044.davem@davemloft.net>
References: <20170927033722.89146-1-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: maze@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50818 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751970AbdI1Rs5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:48:57 -0400
In-Reply-To: <20170927033722.89146-1-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej ¯enczykowski <zenczykowski@gmail.com>
Date: Tue, 26 Sep 2017 20:37:22 -0700

> From: Maciej ¯enczykowski <maze@google.com>
> 
> This function is unused, and furthermore it is buggy since it suffers
> from the same issue that requires IP6_ECN_set_ce() to take a pointer
> to the skb so that it may (in case of CHECKSUM_COMPLETE) update skb->csum
> 
> Instead of fixing it, let's just outright remove it.
> 
> Tested: builds, and 'git grep IP6_ECN_clear' comes up empty
> 
> Signed-off-by: Maciej ¯enczykowski <maze@google.com>

Applied to net-next.
