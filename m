From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 16/23 v3] mlx4_core: Multi-Function MCG support
Date: Wed, 10 Feb 2010 09:35:48 +0200
Message-ID: <15ddcffd1002092335t55b0f7c2g1e3e9d75cdb9541d@mail.gmail.com>
References: <49BFC313.1030901@mellanox.co.il> <4B6AEE30.30202@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B6AEE30.30202-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org> wrote:
> The multicast attachment mechanism is used both by IB and Ethernet,
> so we need to specify for each multicast address (whether it is gid or mac) its protocol.
> For Ethernet addresses, their VEP number should be specified [...] A Ethernet ports now need to [...]

With this patch touching a mechanism which is used by both IB and EN,
I believe it need to be separated into two patches, the 1st changing only
the core/common logic and the 2nd the EN one. Looking on V2, I see that you
did have there two patches: "[21/25 v2] mlx4: Adding protocol fields
to multicast group"
and  "[22/25 v2] mlx4_en: Attaching Multicast addresses"

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
