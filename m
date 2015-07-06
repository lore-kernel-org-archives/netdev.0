From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] rhashtable: fix for resize events during table walk
Date: Mon, 6 Jul 2015 21:53:54 +0800
Message-ID: <20150706135353.GA22998@gondor.apana.org.au>
References: <1436190680-21887-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, sparclinux@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, daniel@iogearbox.net, geert@linux-m68k.org,
	mroos@linux.ee
To: Phil Sutter <phil@nwl.cc>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436190680-21887-1-git-send-email-phil@nwl.cc>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 06, 2015 at 03:51:20PM +0200, Phil Sutter wrote:
> If rhashtable_walk_next detects a resize operation in progress, it jumps
> to the new table and continues walking that one. But it misses to drop
> the reference to it's current item, leading it to continue traversing
> the new table's bucket in which the current item is sorted into, and
> after reaching that bucket's end continues traversing the new table's
> second bucket instead of the first one, thereby potentially missing
> items.
> 
> This fixes the rhashtable runtime test for me. Bug probably introduced
> by Herbert Xu's patch eddee5ba ("rhashtable: Fix walker behaviour during
> rehash") although not explicitly tested.
> 
> Fixes: eddee5ba ("rhashtable: Fix walker behaviour during rehash")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
