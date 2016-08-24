From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: remove clear_sk() method
Date: Tue, 23 Aug 2016 23:37:28 -0700 (PDT)
Message-ID: <20160823.233728.1295346525678892725.davem@davemloft.net>
References: <1471977569-27190-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57583 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751056AbcHXGok (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 02:44:40 -0400
In-Reply-To: <1471977569-27190-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 23 Aug 2016 11:39:25 -0700

> Since IPv6 socket lookups no longer dereference pinet6 pointer
> and UDP lost SLAB_DESTROY_BY_RCU special rules, we no longer
> need special clear_sk() methods.

Series applied, thanks Eric.

There were some merge conflicts because I applied David Ahern's
sock diag udp patches first.

Please double check my work.

Thanks.
