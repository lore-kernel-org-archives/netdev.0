From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH V3 1/5] cxgb4: Add T4 filter support
Date: Mon, 03 Dec 2012 14:02:07 -0500 (EST)
Message-ID: <20121203.140207.164096621247746195.davem@davemloft.net>
References: <1354533781-31575-1-git-send-email-vipul@chelsio.com>
	<1354533781-31575-2-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	abhishek-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1354533781-31575-2-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Mon,  3 Dec 2012 16:52:57 +0530

> +	/*
> +	 * If the new or old filter have loopback rewriteing rules then we'll
> +	 * need to free any existing Layer Two Table (L2T) entries of the old
> +	 * filter rule.  The firmware will handle freeing up any Source MAC
> +	 * Table (SMT) entries used for rewriting Source MAC Addresses in
> +	 * loopback rules.
> +	 */
> +	if (f->l2t)
> +		cxgb4_l2t_release(f->l2t);
> +
> +	/* The zeroing of the filter rule below clears the filter valid,
> +	 * pending, locked flags, l2t pointer, etc. so it's all we need for
> +	 * this operation.
> +	 */

My greatest amusement is achieved when someone gets a code formatting
rule both correct and wrong in the same patch, as you have done here.

Format comments in the networking:

	/* Like
	 * this.
	 */

	 /*
	  * Never,
	  * like this.
	  */

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
