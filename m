From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Sat, 5 Feb 2005 17:14:39 -0800
Message-ID: <20050205171439.4e825155.davem@davemloft.net>
References: <20050131102920.GC4170@suse.de>
	<E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
	<20050203142705.GA11318@krispykreme.ozlabs.ibm.com>
	<20050203203010.GA7081@gondor.apana.org.au>
	<20050203141901.5ce04c92.davem@davemloft.net>
	<20050203235044.GA8422@gondor.apana.org.au>
	<20050203164922.2627a112.davem@davemloft.net>
	<20050204012053.GA8949@gondor.apana.org.au>
	<20050203172357.670c3402.davem@davemloft.net>
	<20050204015539.GA9727@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, okir@suse.de, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050204015539.GA9727@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Feb 2005 12:55:39 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> OK, here is the patch to do that.  Let's get rid of kfree_skb_fast
> while we're at it since it's no longer used.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I've queued this up for 2.6.x and 2.4.x, thanks everyone.
