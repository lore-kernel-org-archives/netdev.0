From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sock: reset sk_err when the error queue is empty
Date: Sun, 04 Jun 2017 20:02:45 -0400 (EDT)
Message-ID: <20170604.200245.1799631200856186565.davem@davemloft.net>
References: <20170602163822.67543-1-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrubis@suse.cz, soheil@google.com,
        edumazet@google.com, willemb@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52698 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751181AbdFEACr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 20:02:47 -0400
In-Reply-To: <20170602163822.67543-1-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Fri,  2 Jun 2017 12:38:22 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Prior to f5f99309fa74 (sock: do not set sk_err in
> sock_dequeue_err_skb), sk_err was reset to the error of
> the skb on the head of the error queue.
> 
> Applications, most notably ping, are relying on this
> behavior to reset sk_err for ICMP packets.
> 
> Set sk_err to the ICMP error when there is an ICMP packet
> at the head of the error queue.
> 
> Fixes: f5f99309fa74 (sock: do not set sk_err in sock_dequeue_err_skb)
> Reported-by: Cyril Hrubis <chrubis@suse.cz>
> Test-by: Cyril Hrubis <chrubis@suse.cz>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable, thank you.
