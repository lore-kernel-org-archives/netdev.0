From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] reduce sizeof(struct inet_peer) from 128 to 64 bytes on
 64bits architectures
Date: Wed, 16 Mar 2005 14:10:57 -0800
Message-ID: <20050316141057.12a8e777.davem@davemloft.net>
References: <42370997.6010302@cosmosbay.com>
	<20050315103253.590c8bfc.davem@davemloft.net>
	<42380EC6.60100@cosmosbay.com>
	<42387579.6090502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <42387579.6090502@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Mar 2005 19:05:45 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> As peer_cachep uses kmem_cache_create("inet_peer_cache", ... SLAB_HWCACHE_ALIGN ...),
> better try to use exactly 64 bytes instead of 72 for struct inet_peer.
> 
> This also means that this structure fits in one cache line on x86_64.

Please resend the patch, your email client turned all the tab
characters into spaces so the patch will not apply.
