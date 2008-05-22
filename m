From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: FW: [PATCH][I/OAT]: Remove duplicate assignation in	dma_skb_copy_datagram_iovec
Date: Thu, 22 May 2008 09:02:19 +0200
Message-ID: <48351A7B.90309@inria.fr>
References: <7F38996F7185A24AB9071ED4950AD8C1013A15FE@swsmsx413.ger.corp.intel.com> <1204305793.31065.4.camel@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, Brice.Goglin@inria.fr,
	"Nelson, Shannon" <shannon.nelson@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:55158 "EHLO smtp3-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752521AbYEVHCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 03:02:23 -0400
In-Reply-To: <1204305793.31065.4.camel@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't see this patch applied anywhere, what happened to it?

Brice



Dan Williams wrote:
> Subject: net_dma: Remove duplicate assignment in dma_skb_copy_datagram_iovec
>
> From: Brice Goglin <Brice.Goglin@inria.fr>
>
> No need to compute copy twice in the frags loop in
> dma_skb_copy_datagram_iovec().
>
> Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
> Hi Maciej,
>
> Please be careful about maintaining attribution of the patch.
>
> Regards,
> Dan
>
>  net/core/user_dma.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
>
> diff --git a/net/core/user_dma.c b/net/core/user_dma.c
> index 0ad1cd5..c77aff9 100644
> --- a/net/core/user_dma.c
> +++ b/net/core/user_dma.c
> @@ -75,7 +75,7 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *chan,
>  
>  		end = start + skb_shinfo(skb)->frags[i].size;
>  		copy = end - offset;
> -		if ((copy = end - offset) > 0) {
> +		if (copy > 0) {
>  			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
>  			struct page *page = frag->page;
>  
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   

