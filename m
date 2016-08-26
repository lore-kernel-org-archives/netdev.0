From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] rhashtable: fix a memory leak in alloc_bucket_locks()
Date: Sat, 27 Aug 2016 00:25:12 +0800
Message-ID: <20160826162512.GA23308@gondor.apana.org.au>
References: <544270328.2536943.1472154674747.JavaMail.zimbra@redhat.com>
 <1474737839.2538727.1472155133819.JavaMail.zimbra@redhat.com>
 <CANn89iL3J6nTbNRm215xv2LL_6SjoPV-XtUJq7Ka_7pFsuAg0g@mail.gmail.com>
 <2107409749.2541400.1472156272168.JavaMail.zimbra@redhat.com>
 <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com>
 <1472226699.14381.186.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, CAI Qian <caiqian@redhat.com>,
        Thomas Graf <tgraf@suug.ch>,
        Eric Dumazet <edumazet@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:39928 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753283AbcHZQZ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 12:25:29 -0400
Content-Disposition: inline
In-Reply-To: <1472226699.14381.186.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 08:51:39AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> If vmalloc() was successful, do not attempt a kmalloc_array()
> 
> Fixes: 4cf0b354d92e ("rhashtable: avoid large lock-array allocations")
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Florian Westphal <fw@strlen.de>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks Eric!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
