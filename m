From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Tue, 11 Jul 2017 13:31:14 -0700 (PDT)
Message-ID: <20170711.133114.2003805526568564614.davem@davemloft.net>
References: <20170710100531.GA14940@gondor.apana.org.au>
        <20170710121002.GB21587@oracle.com>
        <20170710140048.GA15408@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, torvalds@linux-foundation.org,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
        mitr@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170710140048.GA15408@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 10 Jul 2017 22:00:48 +0800

> crypto: af_alg - Avoid sock_graft call warning
> 
> The newly added sock_graft warning triggers in af_alg_accept.
> It's harmless as we're essentially doing sock->sk = sock->sk.
> 
> The sock_graft call is actually redundant because all the work
> it does is subsumed by sock_init_data.  However, it was added
> to placate SELinux as it uses it to initialise its internal state.
> 
> This patch avoisd the warning by making the SELinux call directly.
> 
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: David S. Miller <davem@davemloft.net>

Looks good, is this going via my tree or your's?
