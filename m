From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: get rid of custom busy poll code
Date: Fri, 03 Feb 2017 16:18:23 -0500 (EST)
Message-ID: <20170203.161823.411079635025477871.davem@davemloft.net>
References: <1486061448.21871.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752331AbdBCVSY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:18:24 -0500
In-Reply-To: <1486061448.21871.24.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 10:50:48 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Compared to custom busy_poll, the generic NAPI one is simpler and
> removes a lot of code. It removes one atomic in the fast path (when
> busy poll is not in action) since we do not have to use an extra
> spinlock.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
