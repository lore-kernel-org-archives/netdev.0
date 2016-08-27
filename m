From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rhashtable: fix a memory leak in
 alloc_bucket_locks()
Date: Fri, 26 Aug 2016 22:00:27 -0700 (PDT)
Message-ID: <20160826.220027.82559836629551634.davem@davemloft.net>
References: <2107409749.2541400.1472156272168.JavaMail.zimbra@redhat.com>
        <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com>
        <1472226699.14381.186.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caiqian@redhat.com, tgraf@suug.ch, herbert@gondor.apana.org.au,
        edumazet@google.com, netdev@vger.kernel.org,
        torvalds@linux-foundation.org, fw@strlen.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34285 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbcH0FAo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 01:00:44 -0400
In-Reply-To: <1472226699.14381.186.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 26 Aug 2016 08:51:39 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> If vmalloc() was successful, do not attempt a kmalloc_array()
> 
> Fixes: 4cf0b354d92e ("rhashtable: avoid large lock-array allocations")
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
