From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] RDMA/nes: don't leak skb if carrier down
Date: Thu, 28 Apr 2016 14:20:00 -0400 (EDT)
Message-ID: <20160428.142000.1837221734695213663.davem@davemloft.net>
References: <1461529139-28582-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461529139-28582-1-git-send-email-fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Date: Sun, 24 Apr 2016 22:18:59 +0200

> Alternatively one could free the skb, OTOH I don't think this test is
> useful so just remove it.
> 
> Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> Signed-off-by: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
> ---
>  Noticed this while working on the TX_LOCKED removal.

Assuming Doug will take this.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
