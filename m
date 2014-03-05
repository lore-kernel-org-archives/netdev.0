From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCHv3 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Wed, 5 Mar 2014 13:30:45 +0200
Message-ID: <53170AE5.1030602@mellanox.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	<kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>, <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393936917-25847-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/03/2014 14:41, Hariprasad Shenai wrote:
> Hariprasad Shenai (1):
>    Revert "cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit()"
>
> Kumar Sanghvi (5):
>    cxgb4: Fix some small bugs in t4_sge_init_soft() when our Page Size is
>      64KB
>    cxgb4: Add code to dump SGE registers when hitting idma hangs
>    cxgb4: Rectify emitting messages about SGE Ingress DMA channels being
>      potentially stuck
>    cxgb4: Updates for T5 SGE's Egress Congestion Threshold
>    cxgb4: use spinlock_irqsave/spinlock_irqrestore for db lock.
>
> Steve Wise (25):
>    iw_cxgb4: cap CQ size at T4_MAX_IQ_SIZE.
>    iw_cxgb4: Allow loopback connections.
>    iw_cxgb4: release neigh entry in error paths.
>    iw_cxgb4: Treat CPL_ERR_KEEPALV_NEG_ADVICE as negative advice.
>    cxgb4/iw_cxgb4: Doorbell Drop Avoidance Bug Fixes.
>    iw_cxgb4: use the BAR2/WC path for kernel QPs and T5 devices.
>    iw_cxgb4: Fix incorrect BUG_ON conditions.
>    iw_cxgb4: Mind the sq_sig_all/sq_sig_type QP attributes.
>    iw_cxgb4: default peer2peer mode to 1.
>    iw_cxgb4: save the correct map length for fast_reg_page_lists.
>    iw_cxgb4: don't leak skb in c4iw_uld_rx_handler().
>    iw_cxgb4: fix possible memory leak in RX_PKT processing.
>    iw_cxgb4: ignore read reponse type 1 CQEs.
>    iw_cxgb4: connect_request_upcall fixes.
>    iw_cxgb4: adjust tcp snd/rcv window based on link speed.
>    iw_cxgb4: update snd_seq when sending MPA messages.
>    iw_cxgb4: lock around accept/reject downcalls.
>    iw_cxgb4: drop RX_DATA packets if the endpoint is gone.
>    iw_cxgb4: rx_data() needs to hold the ep mutex.
>    iw_cxgb4: endpoint timeout fixes.
>    iw_cxgb4: rmb() after reading valid gen bit.
>    iw_cxgb4: wc_wmb() needed after DB writes.
>    iw_cxgb4: SQ flush fix.
>    iw_cxgb4: minor fixes
>    iw_cxgb4: Max fastreg depth depends on DSGL support.

Also, not sure if this is addressed by the coding style or patch 
submission guide, but I think the common/proper way to set subject 
(title) line for kernel patches is to avoid a period in the end of the 
sentence, since this is single line. Anyway, you were not consistent 
about this tiny detail... some patches subject line end with period some 
don't, I vote to remove...
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
