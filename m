From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: md5: fix lockdep annotation
Date: Wed, 18 Nov 2015 23:03:38 -0500 (EST)
Message-ID: <20151118.230338.1757197871530382209.davem@davemloft.net>
References: <1447879213.22599.182.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933731AbbKSEDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 23:03:39 -0500
In-Reply-To: <1447879213.22599.182.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Nov 2015 12:40:13 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When a passive TCP is created, we eventually call tcp_md5_do_add()
> with sk pointing to the child. It is not owner by the user yet (we
> will add this socket into listener accept queue a bit later anyway)
> 
> But we do own the spinlock, so amend the lockdep annotation to avoid
> following splat :
 ...
> Fixes: a8afca0329988 ("tcp: md5: protects md5sig_info with RCU")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable, thanks.
