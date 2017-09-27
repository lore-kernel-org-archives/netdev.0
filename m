From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] xfrm: don't call xfrm_policy_cache_flush under
 xfrm_state_lock
Date: Wed, 27 Sep 2017 14:31:03 +0200
Message-ID: <20170927123103.GB14971@breakpoint.cc>
References: <20170927122537.14235-1-asavkov@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Artem Savkov <asavkov@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170927122537.14235-1-asavkov@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Artem Savkov <asavkov@redhat.com> wrote:
> I might be wrong but it doesn't look like xfrm_state_lock is required
> for xfrm_policy_cache_flush and calling it under this lock triggers both
> "sleeping function called from invalid context" and "possible circular
> locking dependency detected" warnings on flush.
> 
> Fixes: ec30d78c14a8 xfrm: add xdst pcpu cache
> Signed-off-by: Artem Savkov <asavkov@redhat.com>

You're right, its not needed (and wrong).

Acked-by: Florian Westphal <fw@strlen.de>
