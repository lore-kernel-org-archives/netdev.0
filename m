From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] virtio_net: Fix skb->csum_start computation
Date: Thu, 29 May 2008 16:48:05 +1000
Message-ID: <20080529064805.GA18007@gondor.apana.org.au>
References: <1211887247-31979-1-git-send-email-markmc@redhat.com>
	<1211887247-31979-2-git-send-email-markmc@redhat.com>
	<1211887247-31979-3-git-send-email-markmc@redhat.com>
	<1211887247-31979-4-git-send-email-markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1211887247-31979-4-git-send-email-markmc@redhat.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, May 27, 2008 at 12:20:47PM +0100, Mark McLoughlin wrote:
> hdr->csum_start is the offset from the start of the ethernet
> header to the transport layer checksum field. skb->csum_start
> is the offset from skb->head.
> 
> skb_partial_csum_set() assumes that skb->data points to the
> ethernet header - i.e. it computes skb->csum_start by adding
> the headroom to hdr->csum_start.
> 
> Since eth_type_trans() skb_pull()s the ethernet header,
> skb_partial_csum_set() should be called before
> eth_type_trans().
> 
> Signed-off-by: Mark McLoughlin <markmc@redhat.com>

Good catch! Clearly shows I never ran this across a real Ethernet
device :)

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
