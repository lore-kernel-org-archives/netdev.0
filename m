From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/2] udp: do fwd memory scheduling on dequeue
Date: Mon, 07 Nov 2016 13:24:58 -0500 (EST)
Message-ID: <20161107.132458.256635426505538931.davem@davemloft.net>
References: <cover.1478254512.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1478254512.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Fri,  4 Nov 2016 11:28:57 +0100

> After commit 850cbaddb52d ("udp: use it's own memory accounting schema"),
> the udp code needs to acquire twice the receive queue spinlock on dequeue.
> 
> This patch series remove the need for the second lock at skb free time,
> moving the udp memory scheduling inside the dequeue operation; the skb
> destructor field is not used anymore and an additional sk argument is added
> to ip_cmsg_recv_offset() to cope with null skb->sk after dequeue.
> 
> Many thanks to Eric Dumazed for suggesting pretty all much the above.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
