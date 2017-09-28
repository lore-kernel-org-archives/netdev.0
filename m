From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: don't call xfrm_policy_cache_flush under
 xfrm_state_lock
Date: Thu, 28 Sep 2017 13:12:32 +0200
Message-ID: <20170928111232.GT3149@secunet.com>
References: <20170927122537.14235-1-asavkov@redhat.com>
 <20170927123103.GB14971@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Artem Savkov <asavkov@redhat.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170927123103.GB14971@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 02:31:03PM +0200, Florian Westphal wrote:
> Artem Savkov <asavkov@redhat.com> wrote:
> > I might be wrong but it doesn't look like xfrm_state_lock is required
> > for xfrm_policy_cache_flush and calling it under this lock triggers both
> > "sleeping function called from invalid context" and "possible circular
> > locking dependency detected" warnings on flush.
> > 
> > Fixes: ec30d78c14a8 xfrm: add xdst pcpu cache
> > Signed-off-by: Artem Savkov <asavkov@redhat.com>
> 
> You're right, its not needed (and wrong).
> 
> Acked-by: Florian Westphal <fw@strlen.de>

Applied to the ipsec tree, thanks everyone!
