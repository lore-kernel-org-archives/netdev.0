From: Amos Kong <kongjianjun@gmail.com>
Subject: Re: [PATCH] macvtap: fix up direction in comment on offloading
Date: Fri, 16 Aug 2013 04:41:26 +0800
Message-ID: <CAFeW=paTeaNsvK7ai-PPs6+MVW3LbaPaW9et_eu3XuGPpMqnuw@mail.gmail.com>
References: <20130815174626.GA10874@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130815174626.GA10874@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 16, 2013 at 1:46 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> It speaks about receiving frames, so while
> it says GSO, it really means GRO.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/macvtap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index a98fb0e..a98ed9f 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -1047,7 +1047,7 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
>          * accept TSO frames and turning it off means that user space
>          * does not support TSO.
>          * For macvtap, we have to invert it to mean the same thing.
> -        * When user space turns off TSO, we turn off GSO/LRO so that
> +        * When user space turns off TSO, we turn off GRO/LRO so that

Right fix.

Reviewed-by: Amos Kong <kongjianjun@gmail.com>

>          * user-space will not receive TSO frames.
>          */
>         if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_UFO))
> --
> MST
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
