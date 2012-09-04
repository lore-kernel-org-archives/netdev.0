From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] RDMA/cxgb4: Update RDMA/cxgb4 due to macro
 definition removal in cxgb4 driver
Date: Tue, 04 Sep 2012 15:59:53 -0400 (EDT)
Message-ID: <20120904.155953.2159440056964789329.davem@davemloft.net>
References: <1346405072-24561-1-git-send-email-vipul@chelsio.com>
	<1346405072-24561-3-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, sivasu-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1346405072-24561-3-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Fri, 31 Aug 2012 14:54:32 +0530

> cxgb4 driver removed the duplicate definitions of registers which requires
> update in RDMA/cxgb4 driver.
> 
> Signed-off-by: Santosh Rastapur <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> Reviewed-by: Sivakumar Subramani <sivasu-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

If you do this in a seperate change, the build is broken between the
two changes.

Never do this, the tree must be fully bisectable and build and work
at each and every step along the way.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
