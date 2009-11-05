From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 08/25] mlx4_core: fix buggy parsing of reserved eq cap
Date: Thu, 05 Nov 2009 12:00:17 -0800
Message-ID: <adaws2468tq.fsf@roland-alpha.cisco.com>
References: <4AF19E2C.6060604@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AF19E2C.6060604-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org> (Yevgeny Petrilin's message of
	"Wed, 04 Nov 2009 17:30:52 +0200")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


 > -	dev_cap->reserved_eqs = 1 << (field & 0xf);
 > +	dev_cap->reserved_eqs = field & 0xf;

This patch looks good to apply right now.  Is it OK for me to make this
"From: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>" and add "Signed-off-by:
Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>"?

 - R.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
