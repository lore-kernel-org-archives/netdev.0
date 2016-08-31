From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: batch calls to flush_all_backlogs()
Date: Tue, 30 Aug 2016 22:17:50 -0700 (PDT)
Message-ID: <20160830.221750.1612733409807577594.davem@davemloft.net>
References: <1472241039.14381.202.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com,
        hannes@stressinduktion.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcHaFRw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 01:17:52 -0400
In-Reply-To: <1472241039.14381.202.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 26 Aug 2016 12:50:39 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit 145dd5f9c88f ("net: flush the softnet backlog in process
> context"), we can easily batch calls to flush_all_backlogs() for all
> devices processed in rollback_registered_many()
> 
> Tested:
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
