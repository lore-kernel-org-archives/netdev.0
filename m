From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: clear sk_err_soft in sk_clone_lock()
Date: Mon, 31 Oct 2016 15:26:26 -0400 (EDT)
Message-ID: <20161031.152626.935222118240640552.davem@davemloft.net>
References: <1477687224.7065.261.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56466 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945584AbcJaT02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:26:28 -0400
In-Reply-To: <1477687224.7065.261.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 Oct 2016 13:40:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> At accept() time, it is possible the parent has a non zero
> sk_err_soft, leftover from a prior error.
> 
> Make sure we do not leave this value in the child, as it
> makes future getsockopt(SO_ERROR) calls quite unreliable.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
