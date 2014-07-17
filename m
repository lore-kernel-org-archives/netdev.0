From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v2 0/4] cxgb4i: Add ipv6 support
Date: Thu, 17 Jul 2014 16:06:28 -0700 (PDT)
Message-ID: <20140717.160628.701122343847367968.davem@davemloft.net>
References: <1405581498-28092-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org
To: anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405581498-28092-1-git-send-email-anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 17 Jul 2014 00:18:14 -0700

>    The following patchset add ipv6 support for the cxgb4i(iscsi) driver.
> 
> Patch 1 moves a define from the iw_cxgb4 to cxgb4 to prevent code duplication,
>  as it is used by cxgb4i and iw_cxgb4 both.
> Patch 2 exports symbols needed by cxgb4i for ipv6 support from cxgb4.
> Patch 3 & 4 deal with actual ipv6 code in libcxgbi/cxgb4i.
> 
> Submitting to net-next as changes were needed in cxgb4/iw_cxgb4, and submitting
> to scsi separately would break compilation, cc-ing scsi & rdma.
> 
> v2 : Cleanup macro that prints ip addresses by using %pIS in patch 3

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
