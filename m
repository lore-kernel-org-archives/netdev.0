From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 10/31] cxgb4/iw_cxgb4: Doorbell Drop Avoidance
 Bug Fixes.
Date: Wed, 26 Feb 2014 18:12:16 -0500 (EST)
Message-ID: <20140226.181216.1563503549713890339.davem@davemloft.net>
References: <1393427230-14532-1-git-send-email-hariprasad@chelsio.com>
	<1393427230-14532-11-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393427230-14532-11-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Wed, 26 Feb 2014 20:36:49 +0530

> -static int allow_db_fc_on_t5;
> -module_param(allow_db_fc_on_t5, int, 0644);
> -MODULE_PARM_DESC(allow_db_fc_on_t5,
> -		 "Allow DB Flow Control on T5 (default = 0)");
> -
> -static int allow_db_coalescing_on_t5;
> -module_param(allow_db_coalescing_on_t5, int, 0644);
> -MODULE_PARM_DESC(allow_db_coalescing_on_t5,
> -		 "Allow DB Coalescing on T5 (default = 0)");

Module parameters are a user facing interface.

You cannot just delete, or change the semantics of, the ones you feel
like doing so to.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
