From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] cls_cgroup: Fix rcu lockdep warning
Date: Fri, 3 Sep 2010 12:52:55 +0800
Message-ID: <20100903045255.GB28300@gondor.apana.org.au>
References: <4C7F446F.8040303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C7F446F.8040303@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 02, 2010 at 02:30:07PM +0800, Li Zefan wrote:
> Calling task_subsys_state() without holding rcu_read_lock or
> cgroup_mutex can cause lockdep warning.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for catching this.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
