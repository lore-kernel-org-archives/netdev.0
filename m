From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] cxgb4: Allocate Tx queues dynamically
Date: Fri, 18 Nov 2016 14:04:46 -0500 (EST)
Message-ID: <20161118.140446.1811222085231950254.davem@davemloft.net>
References: <1479467260-6509-1-git-send-email-atul.gupta@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org,
        jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
        leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
        swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: atul.gupta-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479467260-6509-1-git-send-email-atul.gupta-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Atul Gupta <atul.gupta-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Fri, 18 Nov 2016 16:37:40 +0530

> From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> 
> Allocate resources dynamically for Upper layer driver's (ULD) like
> cxgbit, iw_cxgb4, cxgb4i and chcr. The resources allocated include Tx
> queues which are allocated when ULD register with cxgb4 driver and freed
> while un-registering. The Tx queues which are shared by ULD shall be
> allocated by first registering driver and un-allocated by last
> unregistering driver.
> 
> Signed-off-by: Atul Gupta <atul.gupta-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
