From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] tun: fix issues of iovec iterators using in
 tun_put_user()
Date: Thu, 13 Nov 2014 16:58:38 +0800
Message-ID: <20141113085838.GA3070@gondor.apana.org.au>
References: <1415868854-4913-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1415868854-4913-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 13, 2014 at 04:54:14PM +0800, Jason Wang wrote:
> This patch fixes two issues after using iovec iterators:
> - vlan_offset should be initialized to zero, otherwise unexpected offset
>   will be used in skb_copy_datagram_iter()
> - advance iovec iterator when vnet_hdr_sz is greater than sizeof(gso), this
>   is the case when mergeable rx buffer were enabled for a virt guest.
> 
> Fixes e0b46d0ee9c240c7430a47e9b0365674d4a04522 ("tun: Use iovec iterators")
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Good catch.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
