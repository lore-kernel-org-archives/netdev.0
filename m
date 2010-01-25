From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 01/25 v2] mlx4_core: identify function as pf or vf
Date: Mon, 25 Jan 2010 11:20:04 -0800
Message-ID: <adar5peouu3.fsf@roland-alpha.cisco.com>
References: <4AF3930E.90904@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4AF3930E.90904-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org> (Yevgeny Petrilin's message of
	"Fri, 06 Nov 2009 05:07:58 +0200")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


 >  enum {
 >  	MLX4_FLAG_MSI_X		= 1 << 0,
 >  	MLX4_FLAG_OLD_PORT_CMDS	= 1 << 1,
 > +	MLX4_FLAG_MASTER	= 1 << 2,
 > +	MLX4_FLAG_SLAVE		= 1 << 3,
 > +	MLX4_FLAG_SRIOV		= 1 << 4,
 >  };

I'm a bit confused by these flags.  As far as I can tell, the SRIOV flag
will be set if and only if MASTER is set too... so in other words we
might as well just have the MASTER and SLAVE flags and not have the
SRIOV flag at all.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
