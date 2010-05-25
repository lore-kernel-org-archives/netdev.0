From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linux-next: build failure after merge of the final tree
Date: Tue, 25 May 2010 15:14:42 +1000
Message-ID: <20100525051442.GA8480@gondor.apana.org.au>
References: <20100525141046.975afe1f.sfr@canb.auug.org.au> <20100524.215851.207470612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100524.215851.207470612.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 24, 2010 at 09:58:51PM -0700, David Miller wrote:
> 
> Herbert, can you take a look?

Sorry, I hadn't tested the built-in case.

cls_cgroup: Fix build error when built-in

There is a typo in cgroup_cls_state when cls_cgroup is built-in.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index f9a0b01..4e75a1f 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -31,7 +31,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
 		return 0;
 
 	return container_of(task_subsys_state(p, net_cls_subsys_id),
-			    struct cgroup_cls_state, css).classid;
+			    struct cgroup_cls_state, css)->classid;
 }
 #else
 extern int net_cls_subsys_id;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
