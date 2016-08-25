From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net] qdisc: fix a module refcount leak in
 qdisc_create_dflt()
Date: Thu, 25 Aug 2016 16:44:40 -0700 (PDT)
Message-ID: <20160825.164440.553139896374392567.davem@redhat.com>
References: <1472056742.14381.93.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
        stephen@networkplumber.org, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58254 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933129AbcHYXqa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 19:46:30 -0400
In-Reply-To: <1472056742.14381.93.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Aug 2016 09:39:02 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Should qdisc_alloc() fail, we must release the module refcount
> we got right before.
> 
> Fixes: 6da7c8fcbcbd ("qdisc: allow setting default queuing discipline")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
