From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] tcp: md5: increment sk_drops on syn_recv state
Date: Thu, 25 Aug 2016 16:43:31 -0700 (PDT)
Message-ID: <20160825.164331.414181782282211402.davem@redhat.com>
References: <1472053824.14381.82.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
        julieng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57668 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932973AbcHYXnc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 19:43:32 -0400
In-Reply-To: <1472053824.14381.82.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Aug 2016 08:50:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP MD5 mismatches do increment sk_drops counter in all states but
> SYN_RECV.
> 
> This is very unlikely to happen in the real world, but worth adding
> to help diagnostics.
> 
> We increase the parent (listener) sk_drops.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
