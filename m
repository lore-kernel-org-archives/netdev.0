From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] SLAB_PANIC cleanup
Date: Tue, 17 Aug 2004 10:07:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040817100755.A20489@infradead.org>
References: <Xine.LNX.4.44.0408170237020.7736-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0408170237020.7736-100000@dhcp83-76.boston.redhat.com>; from jmorris@redhat.com on Tue, Aug 17, 2004 at 02:43:38AM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 17, 2004 at 02:43:38AM -0400, James Morris wrote:
>  net/bridge/br_fdb.c: br_fdb_cache = kmem_cache_create("bridge_fdb_cache"
>  net/decnet/dn_table.c:  dn_hash_kmem = kmem_cache_create("dn_fib_info_cache"

Can't these two be modular?
